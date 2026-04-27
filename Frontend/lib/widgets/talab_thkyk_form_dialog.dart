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

class TalabThkykFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const TalabThkykFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<TalabThkykFormDialog> createState() => _TalabThkykFormDialogState();
}

class _TalabThkykFormDialogState extends State<TalabThkykFormDialog> {
  late final Map<String, TextEditingController> c;

  bool _saving = false;
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    c = {
      // Main fields
      'ismMadmoon':       TextEditingController(
          text: e.talabIsmMadmoon ??
              '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim()),
      'raqmhiFiDaman':    TextEditingController(
          text: e.talabRaqmhiFiDaman ??
              e.employeeFundNumber ??
              e.socialSecurityNumber ??
              ''),
      'muassasaWaRaqmuha': TextEditingController(
          text: e.talabMuassasaWaRaqmuha ??
              (e.employerName != null && e.institutionNssfNumber != null
                  ? '${e.employerName} / ${e.institutionNssfNumber}'
                  : e.employerName ?? e.institutionNssfNumber ?? '')),
      'ajrShahri':        TextEditingController(
          text: e.talabAjrShahri ??
              (e.basicSalary != null ? e.basicSalary!.toStringAsFixed(0) : '')),

      // Father / Mother
      'ismWaledWaTarikhWiladatih': TextEditingController(
          text: e.talabIsmWaledWaTarikhWiladatih ?? ''),
      'ismWaledaWaTarikhWiladatiha': TextEditingController(
          text: e.talabIsmWaledaWaTarikhWiladatiha ?? ''),

      // Address
      'qada':             TextEditingController(text: e.talabQada ?? e.district ?? ''),
      'balda':            TextEditingController(text: e.talabBalda ?? e.area ?? ''),
      'share3':           TextEditingController(text: e.talabShare3 ?? e.street ?? ''),
      'milk':             TextEditingController(text: e.talabMilk ?? e.building ?? ''),
      'qurb':             TextEditingController(text: e.talabQurb ?? ''),
      'hatif':            TextEditingController(text: e.talabHatif ?? e.phone ?? ''),

      // Siblings 1–8
      'ashiqqa1':         TextEditingController(text: e.talabAshiqqa1 ?? ''),
      'ashiqqa2':         TextEditingController(text: e.talabAshiqqa2 ?? ''),
      'ashiqqa3':         TextEditingController(text: e.talabAshiqqa3 ?? ''),
      'ashiqqa4':         TextEditingController(text: e.talabAshiqqa4 ?? ''),
      'ashiqqa5':         TextEditingController(text: e.talabAshiqqa5 ?? ''),
      'ashiqqa6':         TextEditingController(text: e.talabAshiqqa6 ?? ''),
      'ashiqqa7':         TextEditingController(text: e.talabAshiqqa7 ?? ''),
      'ashiqqa8':         TextEditingController(text: e.talabAshiqqa8 ?? ''),

      // Parents work & income
      'amalWaledeen':     TextEditingController(text: e.talabAmalWaledeen ?? ''),
      'madakhilWaledeen': TextEditingController(text: e.talabMadakhilWaledeen ?? ''),

      // Subscriber reg num (bottom signature line)
      'raqmiFilDaman':    TextEditingController(
          text: e.talabRaqmiFilDaman ??
              e.employeeFundNumber ??
              e.socialSecurityNumber ??
              ''),
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
      'talab_ism_madmoon':                  ne(c['ismMadmoon']!.text),
      'talab_raqmhi_fi_daman':              ne(c['raqmhiFiDaman']!.text),
      'talab_muassasa_wa_raqmuha':          ne(c['muassasaWaRaqmuha']!.text),
      'talab_ajr_shahri':                   ne(c['ajrShahri']!.text),
      'talab_ism_waled_wa_tarikh_wiladatih':  ne(c['ismWaledWaTarikhWiladatih']!.text),
      'talab_ism_waleda_wa_tarikh_wiladatiha': ne(c['ismWaledaWaTarikhWiladatiha']!.text),
      'talab_qada':                         ne(c['qada']!.text),
      'talab_balda':                        ne(c['balda']!.text),
      'talab_share3':                       ne(c['share3']!.text),
      'talab_milk':                         ne(c['milk']!.text),
      'talab_qurb':                         ne(c['qurb']!.text),
      'talab_hatif':                        ne(c['hatif']!.text),
      'talab_ashiqqa1':                     ne(c['ashiqqa1']!.text),
      'talab_ashiqqa2':                     ne(c['ashiqqa2']!.text),
      'talab_ashiqqa3':                     ne(c['ashiqqa3']!.text),
      'talab_ashiqqa4':                     ne(c['ashiqqa4']!.text),
      'talab_ashiqqa5':                     ne(c['ashiqqa5']!.text),
      'talab_ashiqqa6':                     ne(c['ashiqqa6']!.text),
      'talab_ashiqqa7':                     ne(c['ashiqqa7']!.text),
      'talab_ashiqqa8':                     ne(c['ashiqqa8']!.text),
      'talab_amal_waledeen':                ne(c['amalWaledeen']!.text),
      'talab_madakhil_waledeen':            ne(c['madakhilWaledeen']!.text),
      'talab_raqmi_fil_daman':              ne(c['raqmiFilDaman']!.text),
    };
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    try {
      await ApiService.saveTalabThkykData(widget.employee.id!, _buildDataMap());
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
      await ApiService.saveTalabThkykData(widget.employee.id!, _buildDataMap());
      final pdfBytes = await _generateTalabThkykPdf();
      final fileName =
          'TalabThkyk_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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

  Future<Uint8List> _generateTalabThkykPdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData =
        await rootBundle.load('assets/talab_thkyk_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    // Template: 1024 x 1280 px (portrait)
    const double imgW = 1024;
    const double imgH = 1280;

    String v(String key) => c[key]?.text.trim() ?? '';

    final ts = pw.TextStyle(
        font: arabicFont, fontSize: 9, color: PdfColors.blue900);
    final tsSmall = pw.TextStyle(
        font: arabicFont, fontSize: 8, color: PdfColors.blue900);

    final List<pw.Widget> o = [];

    // Helper: place RTL text (Arabic)
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

    // Helper: place LTR text (numbers)
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

    // ── Row 1: اسم المضمون / رقمه في الضمان ────────────────────
    // اسم المضمون  — right side (RTL text, fills right portion)
    lRtl(658, 262, v('ismMadmoon'),    width: 330);
    // رقمه في الضمان — left side (number, LTR)
    lRtl(198,  262, v('raqmhiFiDaman'), width: 220);

    // ── Row 2: المؤسسة ورقمها ───────────────────────────────────
    lRtl(560, 298, v('muassasaWaRaqmuha'), width: 800);

    // ── Row 3: الاجر الشهري ─────────────────────────────────────
    lRtl(534, 334, v('ajrShahri'), width: 400);

    // ── Row 4: اسم الوالد وتاريخ ولادته ────────────────────────
    lRtl(538, 372, v('ismWaledWaTarikhWiladatih'), width: 620);

    // ── Row 5: اسم الوالدة وتاريخ ولادتها ──────────────────────
    lRtl(528, 408, v('ismWaledaWaTarikhWiladatiha'), width: 620);

    // ── Row 6: عنوان سكن المضمون ────────────────────────────────
    // القضاء
    lRtl(610, 442, v('qada'),   width: 160);
    // البلدة
    lRtl(408, 442, v('balda'),  width: 160);
    // شارع
    lRtl(194, 442, v('share3'), width: 170);

    // ── Row 7: ملك / قرب / هاتف ─────────────────────────────────
    // ملك
    lRtl(606, 478, v('milk'),  width: 110);
    // قرب
    lRtl(408, 478, v('qurb'),  width: 200);
    // هاتف
    lRtl(196,  478, v('hatif'), width: 200);

    // ── Siblings grid ────────────────────────────────────────────
      lRtl(662,  558, v('ashiqqa1'), width: 330);
      lRtl(662,  592, v('ashiqqa2'), width: 330);
      lRtl(662,  626, v('ashiqqa3'), width: 330);
      lRtl(662,  660, v('ashiqqa4'), width: 330);
      lRtl(286,  558, v('ashiqqa5'), width: 330);
      lRtl(286,  592, v('ashiqqa6'), width: 330);
      lRtl(286,  626, v('ashiqqa7'), width: 330);
      lRtl(286,  660, v('ashiqqa8'), width: 330);

    // ── عمل الوالد والوالدة ──────────────────────────────────────
    lRtl(308, 700, v('amalWaledeen'),     width: 760);

    // ── مداخيل الوالدين ──────────────────────────────────────────
    lRtl(478, 738, v('madakhilWaledeen'), width: 760);

    // ── رقمي في الضمان (signature line) ─────────────────────────
    lRtl(212, 774, v('raqmiFilDaman'), width: 200);

    // ── Build PDF ─────────────────────────────────────────────────
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

    Widget row3(Widget a, Widget b, Widget c) => Row(children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
          const SizedBox(width: 8),
          Expanded(child: c),
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
                    colors: [Color(0xFF37474F), Color(0xFF546E7A)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  const Icon(Icons.search_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب اجراء تحقيق اجتماعي',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'CNSS 482 — ${widget.employee.fullName}',
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
                      // ── Subscriber info ──────────────────────────
                      section('بيانات المضمون'),
                      row2(
                        tf('ismMadmoon',    'اسم المضمون'),
                        tf('raqmhiFiDaman', 'رقمه في الضمان', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      tf('muassasaWaRaqmuha', 'المؤسسة ورقمها'),
                      const SizedBox(height: 12),
                      tf('ajrShahri', 'الاجر الشهري',
                          isLtr: true, kb: TextInputType.number),

                      // ── Parents ──────────────────────────────────
                      section('بيانات الوالدين'),
                      tf('ismWaledWaTarikhWiladatih',
                          'اسم الوالد وتاريخ ولادته'),
                      const SizedBox(height: 12),
                      tf('ismWaledaWaTarikhWiladatiha',
                          'اسم الوالدة وتاريخ ولادتها'),

                      // ── Address ──────────────────────────────────
                      section('عنوان سكن المضمون'),
                      row3(
                        tf('qada',   'القضاء'),
                        tf('balda',  'البلدة'),
                        tf('share3', 'شارع'),
                      ),
                      const SizedBox(height: 12),
                      row3(
                        tf('milk',  'ملك'),
                        tf('qurb',  'قرب'),
                        tf('hatif', 'هاتف', isLtr: true, kb: TextInputType.phone),
                      ),

                      // ── Siblings ─────────────────────────────────
                      section('أشقاء وشقيقات المضمون والأعمال التي يمارسونها'),
                      row2(
                        tf('ashiqqa1', '1. الاسم والعمل'),
                        tf('ashiqqa5', '5. الاسم والعمل'),
                      ),
                      const SizedBox(height: 10),
                      row2(
                        tf('ashiqqa2', '2. الاسم والعمل'),
                        tf('ashiqqa6', '6. الاسم والعمل'),
                      ),
                      const SizedBox(height: 10),
                      row2(
                        tf('ashiqqa3', '3. الاسم والعمل'),
                        tf('ashiqqa7', '7. الاسم والعمل'),
                      ),
                      const SizedBox(height: 10),
                      row2(
                        tf('ashiqqa4', '4. الاسم والعمل'),
                        tf('ashiqqa8', '8. الاسم والعمل'),
                      ),

                      // ── Parents work & income ─────────────────────
                      section('معلومات إضافية'),
                      tf('amalWaledeen',
                          'عمل الوالد أو الوالدة قبل بلوغ السن القانوني أو قبل الوفاة'),
                      const SizedBox(height: 12),
                      tf('madakhilWaledeen', 'مداخيل الوالدين'),

                      // ── Subscriber reg num (signature line) ───────
                      section('رقم المضمون في الضمان (للتوقيع)'),
                      tf('raqmiFilDaman', 'رقمي في الضمان', isLtr: true),

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
                    label: Text(
                        _generatingPdf ? 'جاري...' : 'حفظ + إنشاء PDF'),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF37474F)),
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