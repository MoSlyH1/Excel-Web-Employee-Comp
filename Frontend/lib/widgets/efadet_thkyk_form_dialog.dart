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

class EfadetThkykFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const EfadetThkykFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<EfadetThkykFormDialog> createState() => _EfadetThkykFormDialogState();
}

class _EfadetThkykFormDialogState extends State<EfadetThkykFormDialog> {
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
      'companyName': TextEditingController(
          text: e.efadetCompanyName ?? e.employerName ?? ''),
      'cnssRegNum': TextEditingController(
          text: e.efadetCnssRegNum ??
              e.institutionNssfNumber ??
              e.socialSecurityNumber ??
              ''),
      'employeeName': TextEditingController(
          text: e.efadetEmployeeName ??
              '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim()),
      'employeeRegNum': TextEditingController(
          text: e.efadetEmployeeRegNum ??
              e.employeeFundNumber ??
              e.ministryRegistrationNumber ??
              ''),
      'startDate': TextEditingController(
          text: e.efadetStartDate ?? _fmtDt(e.startDate)),
      'monthlySalary': TextEditingController(
          text: e.efadetMonthlySalary ??
              (e.basicSalary != null
                  ? e.basicSalary!.toStringAsFixed(0)
                  : '')),
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

  Map<String, dynamic> _buildDataMap() {
    String? ne(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    return {
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
      final pdfBytes = await _generateThkykPdf();
      final fileName =
          'EfadetThkyk_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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

  Future<Uint8List> _generateThkykPdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData =
        await rootBundle.load('assets/efadet_thkyk_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    // Template: 1024 x 1280 px  (portrait)
    const double imgW = 1024;
    const double imgH = 1280;

    String v(String key) => c[key]?.text.trim() ?? '';

    // Split yyyy-MM-dd → [day, month, year]
    List<String> pd(String date) {
      if (date.isEmpty) return ['', '', ''];
      final p = date.split('-');
      return p.length == 3 ? [p[2], p[1], p[0]] : ['', '', ''];
    }

    final startDt = pd(v('startDate'));   // [day, month, year]
    final declDt  = pd(v('declarationDate'));

    final ts = pw.TextStyle(
        font: arabicFont, fontSize: 10, color: PdfColors.blue900);

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

    // y≈292  تفيد مؤسسة / شركة [companyName] المسجلة في الصندوق
    l(470, 280, v('companyName'),    width: 580);

    // y≈328  تحت رقم [cnssRegNum]   ان المضمون [employeeName]
    l(428, 314, v('cnssRegNum'),     width: 310);
    l(720, 352, v('employeeName'),   width: 173);

    // y≈363  رقمه [employeeRegNum]  قد بدأ العمل لدينا بدوام كامل
    l(454, 352, v('employeeRegNum'), width: 362);

    // y≈430  اعتبارا من تاريخ [day]/[mon]/[year]  راتبا شهريا قدره [salary]
    l( 272, 386, v('monthlySalary'), width: 411);  // salary — leftmost zone
    l(614, 386, startDt[2],         width: 118);  // year
    l(660, 386, startDt[1],         width:  60);  // month
    l(684, 386, startDt[0],         width:  60);  // day  — rightmost

    // y≈515  التاريخ  [day] / [mon] / [year]   الخاتم والتوقيع
    l(420, 494, declDt[2],  width:  98);   // year
    l(502, 494, declDt[1],  width:  40);   // month
    l(562, 494, declDt[0],  width:  47);   // day

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(imgW, imgH),
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(children: [
            pw.Positioned.fill(
              child: pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Image(templateImage, width: imgW, height: imgH),
              ),
            ),
            ...o,
          ]),
        ),
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    const rtl = ui.TextDirection.rtl;
    const ltr = ui.TextDirection.ltr;

    InputDecoration dec(String label, {String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        );

    Widget tf(String key, String label,
        {bool isLtr = false, TextInputType? kb, String? hint}) {
      return TextField(
        controller: c[key],
        textDirection: isLtr ? ltr : rtl,
        decoration: dec(label, hint: hint),
        keyboardType: kb,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 720),
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────
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
                  const Icon(Icons.fact_check_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إفادة تحقيق',
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

              // ── Body ────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      section('بيانات الشركة / المؤسسة'),
                      row2(
                        tf('companyName', 'اسم الشركة / المؤسسة'),
                        tf('cnssRegNum', 'رقم تسجيل الصندوق', isLtr: true),
                      ),

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

              // ── Footer ──────────────────────────────────────────
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
                    onPressed: _saving || _generatingPdf ? null : _saveOnly,
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
                        : const Icon(Icons.picture_as_pdf_rounded, size: 18),
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