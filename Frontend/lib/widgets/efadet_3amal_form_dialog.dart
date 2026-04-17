import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/employee.dart';
import '../services/api_service.dart';

class EfadetAmalFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const EfadetAmalFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<EfadetAmalFormDialog> createState() => _EfadetAmalFormDialogState();
}

class _EfadetAmalFormDialogState extends State<EfadetAmalFormDialog> {
  late final Map<String, TextEditingController> c;

  bool _saving = false;
  bool _generatingPdf = false;

  String _fmtDt(DateTime? d) =>
      d != null ? DateFormat('yyyy-MM-dd').format(d) : '';

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    c = {
      // ── CNSS Office header ────────────────────────────────────
      'incomingNumber': TextEditingController(text: e.efadetIncomingNumber ?? ''),
      'incomingDate':   TextEditingController(text: e.efadetIncomingDate ?? ''),
      'officeName':     TextEditingController(text: e.efadetOfficeName ?? ''),

      // ── Company / Institution ─────────────────────────────────
      'companyName': TextEditingController(
          text: e.efadetCompanyName ?? e.employerName ?? 'شركة ابولا ديليس ش.م.ل'),
      'cnssRegNum': TextEditingController(
          text: e.efadetCnssRegNum ??
              e.institutionNssfNumber ??
              e.socialSecurityNumber ??
              ''),

      // ── Employee (المضمون) ────────────────────────────────────
      'employeeName': TextEditingController(
          text: e.efadetEmployeeName ??
              '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim()),
      'employeeRegNum': TextEditingController(
          text: e.efadetEmployeeRegNum ??
              e.employeeFundNumber ??
              e.ministryRegistrationNumber ??
              ''),

      // ── Work start date & salary ──────────────────────────────
      'startDate': TextEditingController(
          text: e.efadetStartDate ?? _fmtDt(e.startDate)),
      'monthlySalary': TextEditingController(
          text: e.efadetMonthlySalary ??
              (e.basicSalary != null
                  ? e.basicSalary!.toStringAsFixed(0)
                  : '')),

      // ── Declaration date ──────────────────────────────────────
      'declarationDate': TextEditingController(
          text: e.efadetDeclarationDate ??
              DateFormat('yyyy-MM-dd').format(DateTime.now())),
    };
  }

  @override
  void dispose() {
    for (final ctrl in c.values) ctrl.dispose();
    super.dispose();
  }

  // ── Persist to backend ──────────────────────────────────────────────
  Map<String, dynamic> _buildDataMap() {
    String? ne(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    return {
      'efadet_incoming_number':  ne(c['incomingNumber']!.text),
      'efadet_incoming_date':    ne(c['incomingDate']!.text),
      'efadet_office_name':      ne(c['officeName']!.text),
      'efadet_company_name':     ne(c['companyName']!.text),
      'efadet_cnss_reg_num':     ne(c['cnssRegNum']!.text),
      'efadet_employee_name':    ne(c['employeeName']!.text),
      'efadet_employee_reg_num': ne(c['employeeRegNum']!.text),
      'efadet_start_date':       ne(c['startDate']!.text),
      'efadet_monthly_salary':   ne(c['monthlySalary']!.text),
      'efadet_declaration_date': ne(c['declarationDate']!.text),
    };
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    try {
      await ApiService.saveEfadetAmalData(widget.employee.id!, _buildDataMap());
      widget.onDataChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحفظ بنجاح!'),
            backgroundColor: Color(0xFF00897B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _saving = false);
  }

  Future<void> _saveAndGeneratePdf() async {
    setState(() => _generatingPdf = true);
    try {
      await ApiService.saveEfadetAmalData(widget.employee.id!, _buildDataMap());
      final pdfBytes = await _generateEfadetPdf();
      final fileName =
          'EfadetAmal_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      await ApiService.uploadDocuments(
        employeeId: widget.employee.id!,
        fileNames: [fileName],
        fileBytes: [pdfBytes],
        mimeTypes: ['application/pdf'],
      );
      widget.onDataChanged();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ PDF "$fileName"!'),
            backgroundColor: const Color(0xFF00897B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _generatingPdf = false);
  }

  // ════════════════════════════════════════════════════════════════════
  // PDF GENERATION  —  Template: assets/efadet_amal_template_blank.png
  // ════════════════════════════════════════════════════════════════════
  Future<Uint8List> _generateEfadetPdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData =
        await rootBundle.load('assets/efadet_3amal_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    String v(String key) => c[key]?.text.trim() ?? '';

    // Split yyyy-MM-dd → [day, month, year]
    List<String> pd(String date) {
      if (date.isEmpty) return ['', '', ''];
      final p = date.split('-');
      return p.length == 3 ? [p[2], p[1], p[0]] : ['', '', ''];
    }

    final startDt  = pd(v('startDate'));
    final declDt   = pd(v('declarationDate'));
    final incomeDt = pd(v('incomingDate'));

    final ts = pw.TextStyle(
        font: arabicFont, fontSize: 9, color: PdfColors.blue900);

    final List<pw.Widget> o = [];

    void l(double left, double top, String text,
        {required double width, pw.TextStyle? style}) {
      if (text.isEmpty) return;
      o.add(pw.Positioned(
        left: left,
        top: top,
        child: pw.Container(
          width: width,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            text,
            style: style ?? ts,
            textDirection: pw.TextDirection.ltr,
            textAlign: pw.TextAlign.left,
            maxLines: 1,
          ),
        ),
      ));
    }

    // ── TOP-RIGHT header block ────────────────────────────────────
    //l(700, 148, v('officeName'),     width: 220); // مكتب
    //l(792, 174, v('incomingNumber'), width: 220); // رقم الوارد
    //l(824, 210, incomeDt[0],         width: 40);  // day
    //l(772, 210, incomeDt[1],         width: 40);  // month
    //l(700, 210, incomeDt[2],         width: 60);  // year

    // ── Body ─────────────────────────────────────────────────────
    l(516,  322, v('companyName'),    width: 300); // تفيد مؤسسة / شركة
    l(476, 360, v('cnssRegNum'),     width: 200); // تحت رقم
    l(754, 396, v('employeeName'),   width: 360); // أن المضمون
    l(484, 394, v('employeeRegNum'), width: 200); // رقمه

    // اعتباراً من تاريخ
    l(710, 432, startDt[0],          width: 45);  // day
    l(680, 432, startDt[1],          width: 45);  // month
    l(628, 432, startDt[2],          width: 55);  // year

    l(296, 432, v('monthlySalary'),  width: 220); // راتباً شهرياً قدره

    // التاريخ
    l(586, 540, declDt[0],           width: 45);  // day
    l(532, 540, declDt[1],           width: 45);  // month
    l(448, 540, declDt[2],           width: 55);  // year

    // ── Build PDF ─────────────────────────────────────────────────
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(1024, 1280),
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(children: [
            pw.Positioned.fill(
              child: pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Image(templateImage, width: 1024, height: 1280),
              ),
            ),
            ...o,
          ]),
        ),
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  // ════════════════════════════════════════════════════════════════════
  // DIALOG UI
  // ════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    const rtl = ui.TextDirection.rtl;
    const ltr = ui.TextDirection.ltr;

    InputDecoration dec(String label, {String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        );

    Widget tf(String key, String label,
        {bool isLtr = false,
        TextInputType? kb,
        String? hint,
        int maxLines = 1}) {
      return TextField(
        controller: c[key],
        textDirection: isLtr ? ltr : rtl,
        decoration: dec(label, hint: hint),
        keyboardType: kb,
        maxLines: maxLines,
      );
    }

    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: Row(children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: const Color(0xFF1A237E),
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ]),
        );

    Widget row2(Widget a, Widget b) => Row(children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ]);

    return Directionality(
      textDirection: rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 700, maxHeight: 820),
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF283593)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  const Icon(Icons.badge_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إفادة عمل وراتب',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'CNSS 489 — ${widget.employee.fullName}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ]),
              ),

              // ── Body ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── CNSS Office Header ──────────────────
                      section('بيانات مكتب الصندوق'),
                      row2(
                        tf('officeName', 'مكتب'),
                        tf('incomingNumber', 'رقم الوارد', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('incomingDate', 'تاريخ',
                            isLtr: true, hint: 'YYYY-MM-DD'),
                        Container(),
                      ),

                      // ── Company ─────────────────────────────
                      section('بيانات الشركة / المؤسسة'),
                      row2(
                        tf('companyName', 'اسم الشركة / المؤسسة'),
                        tf('cnssRegNum',
                            'المسجلة في الصندوق الوطني تحت رقم',
                            isLtr: true),
                      ),

                      // ── Employee ────────────────────────────
                      section('بيانات المضمون'),
                      row2(
                        tf('employeeName', 'اسم المضمون'),
                        tf('employeeRegNum', 'رقمه', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('startDate', 'تاريخ بدء العمل',
                            isLtr: true, hint: 'YYYY-MM-DD'),
                        tf('monthlySalary', 'الراتب الشهري (قدره)',
                            isLtr: true, kb: TextInputType.number),
                      ),

                      // ── Declaration Date ────────────────────
                      section('التاريخ'),
                      row2(
                        tf('declarationDate', 'تاريخ الإفادة',
                            isLtr: true, hint: 'YYYY-MM-DD'),
                        Container(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed:
                        _saving || _generatingPdf ? null : _saveOnly,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(_saving ? '...' : 'حفظ فقط'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saving || _generatingPdf
                        ? null
                        : _saveAndGeneratePdf,
                    icon: _generatingPdf
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.picture_as_pdf_rounded,
                            size: 18),
                    label: Text(
                        _generatingPdf ? 'جاري...' : 'حفظ + إنشاء PDF'),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E)),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}