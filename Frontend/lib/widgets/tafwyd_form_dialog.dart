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

class TfwydFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const TfwydFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<TfwydFormDialog> createState() => _TfwydFormDialogState();
}

class _TfwydFormDialogState extends State<TfwydFormDialog> {
  late final Map<String, TextEditingController> c;

  bool _saving = false;
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    c = {
      // المستدعي — the claimant/delegate receiving the summons
      // This is the employee who will receive/sign (اسم الأجير field in the form body)
      'mustadei': TextEditingController(
          text: e.tfwydMustadei ??
              '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim()),

      // اسم المؤسسة
      'ismMuassasa': TextEditingController(
          text: e.tfwydIsmMuassasa ?? e.employerName ?? ''),

      // رقم تسجيلها في الصندوق
      'raqmTasjilFiSunduq': TextEditingController(
          text: e.tfwydRaqmTasjilFiSunduq ??
              e.institutionNssfNumber ??
              ''),

      // عنوان المؤسسة
      'unwanMuassasa': TextEditingController(
          text: e.tfwydUnwanMuassasa ??
              e.institutionFullAddress ??
              ''),

      // رقم الهاتف
      'raqmHatif': TextEditingController(
          text: e.tfwydRaqmHatif ??
              e.institutionPhone ??
              e.phone ??
              ''),

      // اسم المسؤول وصفته
      'ismMasoolWaSifatuh': TextEditingController(
          text: e.tfwydIsmMasoolWaSifatuh ??
              (e.institutionResponsible != null
                  ? '${e.institutionResponsible}'
                      '${e.employerTitle != null ? ' / ${e.employerTitle}' : ''}'
                  : '')),

      // اسم الأجير (the employee being delegated)
      'ismAjir': TextEditingController(
          text: e.tfwydIsmAjir ??
              '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim()),
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
      'tfwyd_mustadei':               ne(c['mustadei']!.text),
      'tfwyd_ism_muassasa':           ne(c['ismMuassasa']!.text),
      'tfwyd_raqm_tasjil_fi_sunduq':  ne(c['raqmTasjilFiSunduq']!.text),
      'tfwyd_unwan_muassasa':         ne(c['unwanMuassasa']!.text),
      'tfwyd_raqm_hatif':             ne(c['raqmHatif']!.text),
      'tfwyd_ism_masool_wa_sifatuh':  ne(c['ismMasoolWaSifatuh']!.text),
      'tfwyd_ism_ajir':               ne(c['ismAjir']!.text),
    };
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    try {
      await ApiService.saveTfwydData(widget.employee.id!, _buildDataMap());
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
      await ApiService.saveTfwydData(widget.employee.id!, _buildDataMap());
      final pdfBytes = await _generateTfwydPdf();
      final fileName =
          'Tfwyd_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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

  Future<Uint8List> _generateTfwydPdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData =
        await rootBundle.load('assets/tafwyd_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    // Template: 1024 × 1280 px (portrait)
    const double imgW = 1024;
    const double imgH = 1280;

    String v(String key) => c[key]?.text.trim() ?? '';

    final ts = pw.TextStyle(
        font: arabicFont, fontSize: 9, color: PdfColors.blue900);
    // ignore: unused_local_variable
    final tsSmall = pw.TextStyle(
        font: arabicFont, fontSize: 8, color: PdfColors.blue900);

    final List<pw.Widget> o = [];

    // ── Helper: RTL text anchored by its RIGHT edge ──────────────
    void lRtl(double right, double top, String text,
    {required double width, pw.TextStyle? style}) {
  if (text.isEmpty) return;
  o.add(pw.Positioned(
    left: right - width,   // convert right-anchor → left position
    top: top,
    child: pw.Container(
      width: width,
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        text,
        style: style ?? ts,
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.right,
        maxLines: 1,
      ),
    ),
  ));
}

    // ── Helper: LTR text (numbers / Latin) ───────────────────────
    // ignore: unused_element
    void lLtr(double left, double top, String text,
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

    // ────────────────────────────────────────────────────────────
    //  FIELD PLACEMENT
    //  All Y-coordinates are measured from the TOP of the 1280 px
    //  image.  Adjust if your scanned template differs.
    // ────────────────────────────────────────────────────────────

    // المستدعي  (top of the form, after the header paragraph)
    lRtl(348, 324, v('mustadei'), width: 620);

    // نفوض … الأجير / مندوب المؤسسة السيد  (delegate line)
    lRtl(296, 562, v('ismAjir'), width: 520);

    // اسم المؤسسة
    lRtl(522, 662, v('ismMuassasa'), width: 640);

    // رقم تسجيلها في الصندوق
    lRtl(522, 702, v('raqmTasjilFiSunduq'), width: 640);

    // عنوان المؤسسة
    lRtl(522, 742, v('unwanMuassasa'), width: 640);

    // رقم الهاتف
    lRtl(522, 782, v('raqmHatif'), width: 640);

    // اسم المسؤول وصفته
    lRtl(522, 822, v('ismMasoolWaSifatuh'), width: 640);

    // اسم الأجير (second occurrence — bottom block)
    lRtl(522, 862, v('ismAjir'), width: 640);

    // ── Build PDF ────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────
  //  UI
  // ─────────────────────────────────────────────────────────────────
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
                  color: const Color(0xFF37474F),
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
          constraints: const BoxConstraints(maxWidth: 750, maxHeight: 820),
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  const Icon(Icons.assignment_ind_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفويض باستلام الدعوة لتسديد المبالغ المستحقة',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'صندوق تعويض نهاية الخدمة — ${widget.employee.fullName}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
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
                      // ── المستدعي ─────────────────────────────────
                      section('المستدعي'),
                      tf('mustadei', 'المستدعي (الطرف المُفوَّض)'),

                      // ── المؤسسة ──────────────────────────────────
                      section('بيانات المؤسسة'),
                      tf('ismMuassasa', 'اسم المؤسسة'),
                      const SizedBox(height: 12),
                      row2(
                        tf('raqmTasjilFiSunduq', 'رقم تسجيلها في الصندوق',
                            isLtr: true,
                            kb: TextInputType.number),
                        tf('raqmHatif', 'رقم الهاتف',
                            isLtr: true,
                            kb: TextInputType.phone),
                      ),
                      const SizedBox(height: 12),
                      tf('unwanMuassasa', 'عنوان المؤسسة'),
                      const SizedBox(height: 12),
                      tf('ismMasoolWaSifatuh', 'اسم المسؤول وصفته'),

                      // ── الأجير ────────────────────────────────────
                      section('الأجير / مندوب المؤسسة'),
                      tf('ismAjir', 'اسم الأجير'),

                      const SizedBox(height: 8),
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
                    label:
                        Text(_generatingPdf ? 'جاري...' : 'حفظ + إنشاء PDF'),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4A148C)),
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