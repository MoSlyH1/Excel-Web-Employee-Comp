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

class EfadetAlkasebFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const EfadetAlkasebFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<EfadetAlkasebFormDialog> createState() =>
      _EfadetAlkasebFormDialogState();
}

class _EfadetAlkasebFormDialogState extends State<EfadetAlkasebFormDialog> {
  late final Map<String, TextEditingController> c;

  // Wage type selection: 'shahri' | 'usbui' | 'yawmi' | 'saaa'
  String _selectedWageType = 'shahri';

  bool _saving = false;
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    // Pre-select wage type if saved
    if (e.alkasebWageType != null && e.alkasebWageType!.isNotEmpty) {
      _selectedWageType = e.alkasebWageType!;
    }

    c = {
      // Institution block
      'muassasa':      TextEditingController(
          text: e.alkasebMuassasa ??
              e.employerName ?? ''),
      'raqmuha':       TextEditingController(
          text: e.alkasebRaqmuha ??
              e.institutionNssfNumber ?? ''),
      'unwan':         TextEditingController(
          text: e.alkasebUnwan ??
              e.institutionFullAddress ?? ''),
      'hatif':         TextEditingController(
          text: e.alkasebHatif ??
              e.institutionPhone ?? ''),
      'baridElektroni': TextEditingController(
          text: e.alkasebBaridElektroni ?? ''),

      // Employee block
      'ismMadmoon':    TextEditingController(
          text: e.alkasebIsmMadmoon ??
              '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim()),
      'raqmuhu':       TextEditingController(
          text: e.alkasebRaqmuhu ??
              e.employeeFundNumber ??
              e.socialSecurityNumber ?? ''),

      // Work period
      'minTarikh':     TextEditingController(
          text: e.alkasebMinTarikh ??
              (e.startDate != null
                  ? DateFormat('dd-MM-yyyy').format(e.startDate!)
                  : '')),
      'lighayet':      TextEditingController(
          text: e.alkasebLighayet ??
              (e.endDate != null
                  ? DateFormat('dd-MM-yyyy').format(e.endDate!)
                  : '')),

      // Shahri (monthly)
      'ajrShahriAkhir': TextEditingController(
          text: e.alkasebAjrShahriAkhir ??
              (e.basicSalary != null
                  ? e.basicSalary!.toStringAsFixed(0)
                  : '')),
      'faqatShahri':   TextEditingController(
          text: e.alkasebFaqatShahri ?? ''),

      // Usbui (weekly)
      'adadAsabii':    TextEditingController(
          text: e.alkasebAdadAsabii ?? ''),
      'ajrUsbuyiAkhir': TextEditingController(
          text: e.alkasebAjrUsbuyiAkhir ?? ''),
      'faqatUsbui':    TextEditingController(
          text: e.alkasebFaqatUsbui ?? ''),

      // Yawmi (daily)
      'adadAyyam':     TextEditingController(
          text: e.alkasebAdadAyyam ?? ''),
      'ajrYawmiAkhir': TextEditingController(
          text: e.alkasebAjrYawmiAkhir ?? ''),
      'faqatYawmi':    TextEditingController(
          text: e.alkasebFaqatYawmi ?? ''),

      // Saaa (hourly)
      'majmuSaaat':    TextEditingController(
          text: e.alkasebMajmuSaaat ?? ''),
      'ajrSaaAkhira':  TextEditingController(
          text: e.alkasebAjrSaaAkhira ?? ''),
      'faqatSaaa':     TextEditingController(
          text: e.alkasebFaqatSaaa ?? ''),

      // Signature block
      'ismMasool':     TextEditingController(
          text: e.alkasebIsmMasool ?? ''),
      'sifatMasool':   TextEditingController(
          text: e.alkasebSifatMasool ?? ''),

      // Employee / beneficiary signature block
      'almuwaqiAdnah': TextEditingController(
          text: e.alkasebAlmuwaqiAdnah ??
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
      'alkaseb_muassasa':          ne(c['muassasa']!.text),
      'alkaseb_raqmuha':           ne(c['raqmuha']!.text),
      'alkaseb_unwan':             ne(c['unwan']!.text),
      'alkaseb_hatif':             ne(c['hatif']!.text),
      'alkaseb_barid_elektroni':   ne(c['baridElektroni']!.text),
      'alkaseb_ism_madmoon':       ne(c['ismMadmoon']!.text),
      'alkaseb_raqmuhu':           ne(c['raqmuhu']!.text),
      'alkaseb_min_tarikh':        ne(c['minTarikh']!.text),
      'alkaseb_lighayet':          ne(c['lighayet']!.text),
      'alkaseb_wage_type':         _selectedWageType,
      'alkaseb_ajr_shahri_akhir':  ne(c['ajrShahriAkhir']!.text),
      'alkaseb_faqat_shahri':      ne(c['faqatShahri']!.text),
      'alkaseb_adad_asabii':       ne(c['adadAsabii']!.text),
      'alkaseb_ajr_usbuy_akhir':   ne(c['ajrUsbuyiAkhir']!.text),
      'alkaseb_faqat_usbui':       ne(c['faqatUsbui']!.text),
      'alkaseb_adad_ayyam':        ne(c['adadAyyam']!.text),
      'alkaseb_ajr_yawmi_akhir':   ne(c['ajrYawmiAkhir']!.text),
      'alkaseb_faqat_yawmi':       ne(c['faqatYawmi']!.text),
      'alkaseb_majmu_saaat':       ne(c['majmuSaaat']!.text),
      'alkaseb_ajr_saa_akhira':    ne(c['ajrSaaAkhira']!.text),
      'alkaseb_faqat_saaa':        ne(c['faqatSaaa']!.text),
      'alkaseb_ism_masool':        ne(c['ismMasool']!.text),
      'alkaseb_sifat_masool':      ne(c['sifatMasool']!.text),
      'alkaseb_almuwaqi_adnah':    ne(c['almuwaqiAdnah']!.text),
    };
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    try {
      await ApiService.saveEfadetAlkasebData(
          widget.employee.id!, _buildDataMap());
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
      await ApiService.saveEfadetAlkasebData(
          widget.employee.id!, _buildDataMap());
      final pdfBytes = await _generatePdf();
      final fileName =
          'EfadetAlkaseb_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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

  Future<Uint8List> _generatePdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData =
        await rootBundle.load('assets/efadet_alkaseb_template_blank.png');
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

    // Helper: RTL text anchored to the right edge of a box
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

    // Helper: LTR text anchored to the left edge of a box
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

    // Helper: draw a filled square "checkbox" mark
    void checkBox(double left, double top) {
      o.add(pw.Positioned(
        left: left,
        top: top,
        child: pw.Container(
          width: 10,
          height: 10,
          color: PdfColors.blue900,
        ),
      ));
    }

    // ── Row 1: تفيد مؤسسة / رقمها ──────────────────────────
    lRtl(752, 240, v('muassasa'),  width: 380);
    lRtl(220, 258, v('raqmuha'),   width: 130);

    // ── Row 2: العنوان ──────────────────────────────────────
    lRtl(760, 272, v('unwan'),     width: 620);

    // ── Row 3: هاتف / بريد إلكتروني ────────────────────────
    lRtl(864,  302, v('hatif'),          width: 180);
    lRtl(574, 302, v('baridElektroni'), width: 300);

    // ── Row 4: ان المضمون / رقمه ───────────────────────────
    lRtl(722, 330, v('ismMadmoon'), width: 380);
    lRtl(188, 344, v('raqmuhu'),    width: 130);

    // ── Row 5: عمل لحسابها من تاريخ / لغاية ───────────────
    lRtl(722,  364, v('minTarikh'), width: 160);
    lRtl(464, 364, v('lighayet'),  width: 160);

    // ── Wage type rows ──────────────────────────────────────
    // Checkbox X positions (left edge of the checkbox square on the form)
    const double cbX = 944;

    // ── Shahri ─────────────────────────────────────────────
    if (_selectedWageType == 'shahri') checkBox(cbX, 442);
    lRtl(330, 426, v('ajrShahriAkhir'), width: 260);
    lRtl(684, 462, v('faqatShahri'),    width: 760, style: tsSmall);

    // ── Usbui ──────────────────────────────────────────────
    if (_selectedWageType == 'usbui') checkBox(cbX, 510);
    lRtl(616, 492, v('adadAsabii'),      width: 200);
    lRtl(252, 492, v('ajrUsbuyiAkhir'),  width: 200);
    lRtl(676, 524, v('faqatUsbui'),      width: 760, style: tsSmall);

    // ── Yawmi ──────────────────────────────────────────────
    if (_selectedWageType == 'yawmi') checkBox(cbX, 572);
    lRtl(564, 554, v('adadAyyam'),       width: 200);
    lRtl(232, 554, v('ajrYawmiAkhir'),   width: 200);
    lRtl(666, 588, v('faqatYawmi'),      width: 760, style: tsSmall);

    // ── Saaa ───────────────────────────────────────────────
    if (_selectedWageType == 'saaa') checkBox(cbX, 634);
    lRtl(596, 618, v('majmuSaaat'),      width: 200);
    lRtl(258, 618, v('ajrSaaAkhira'),    width: 200);
    lRtl(668, 654, v('faqatSaaa'),       width: 760, style: tsSmall);

    // ── Signature block: اسم المسؤول وصفته ─────────────────
    lRtl(810, 760, v('ismMasool'),   width: 280);
    lRtl(808, 798, v('sifatMasool'), width: 280);

    // ── Employee / beneficiary signature: الموقع أدناه ─────
    lRtl(462, 934, v('almuwaqiAdnah'), width: 300);

    // ── Build PDF ───────────────────────────────────────────
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

    Widget row3(Widget a, Widget b, Widget cc) => Row(children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
          const SizedBox(width: 8),
          Expanded(child: cc),
        ]);

    // Wage type radio tile builder
    Widget wageTile(String value, String label, List<Widget> fields) {
      final selected = _selectedWageType == value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF006064).withOpacity(0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF006064).withOpacity(0.4)
                : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RadioListTile<String>(
              value: value,
              groupValue: _selectedWageType,
              onChanged: (v) => setState(() => _selectedWageType = v!),
              title: Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: selected
                      ? const Color(0xFF006064)
                      : const Color(0xFF37474F),
                ),
              ),
              activeColor: const Color(0xFF006064),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              dense: true,
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: fields,
                ),
              ),
          ],
        ),
      );
    }

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
                    colors: [Color(0xFF006064), Color(0xFF00838F)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  const Icon(Icons.receipt_long_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إفادة بالأجر أو الكسب الأخير',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'CNSS 207 — ${widget.employee.fullName}',
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
                      // ── Institution ──────────────────────────────
                      section('بيانات المؤسسة'),
                      row2(
                        tf('muassasa', 'تفيد مؤسسة'),
                        tf('raqmuha', 'رقمها', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      tf('unwan', 'العنوان'),
                      const SizedBox(height: 12),
                      row2(
                        tf('hatif', 'هاتف',
                            isLtr: true, kb: TextInputType.phone),
                        tf('baridElektroni', 'بريد إلكتروني',
                            isLtr: true, kb: TextInputType.emailAddress),
                      ),

                      // ── Employee ─────────────────────────────────
                      section('بيانات المضمون'),
                      row2(
                        tf('ismMadmoon', 'ان المضمون'),
                        tf('raqmuhu', 'رقمه', isLtr: true),
                      ),

                      // ── Work period ──────────────────────────────
                      section('فترة العمل'),
                      row2(
                        tf('minTarikh', 'عمل لحسابها من تاريخ',
                            isLtr: true, hint: 'DD-MM-YYYY'),
                        tf('lighayet', 'لغاية',
                            isLtr: true, hint: 'DD-MM-YYYY'),
                      ),

                      // ── Wage type ────────────────────────────────
                      section('نوع الأجر — وكان أجره محدداً على أساس'),

                      // Shahri
                      wageTile('shahri', 'شهري', [
                        tf('ajrShahriAkhir',
                            'مقدار أجره عن الشهر الأخير مع جميع لواحقه (ل.ل.)',
                            isLtr: true, kb: TextInputType.number),
                        const SizedBox(height: 8),
                        tf('faqatShahri', 'فقط (كتابةً)'),
                      ]),

                      // Usbui
                      wageTile('usbui', 'أسبوعي', [
                        row2(
                          tf('adadAsabii', 'عدد أسابيع العمل',
                              isLtr: true, kb: TextInputType.number),
                          tf('ajrUsbuyiAkhir', 'أجره عن الأسبوع الأخير (ل.ل.)',
                              isLtr: true, kb: TextInputType.number),
                        ),
                        const SizedBox(height: 8),
                        tf('faqatUsbui', 'فقط (كتابةً)'),
                      ]),

                      // Yawmi
                      wageTile('yawmi', 'يومي', [
                        row2(
                          tf('adadAyyam',
                              'عدد أيام العمل منذ انتسابه',
                              isLtr: true, kb: TextInputType.number),
                          tf('ajrYawmiAkhir', 'أجره اليومي الأخير (ل.ل.)',
                              isLtr: true, kb: TextInputType.number),
                        ),
                        const SizedBox(height: 8),
                        tf('faqatYawmi', 'فقط (كتابةً)'),
                      ]),

                      // Saaa
                      wageTile('saaa', 'بالساعة', [
                        row2(
                          tf('majmuSaaat', 'مجموع ساعات العمل',
                              isLtr: true, kb: TextInputType.number),
                          tf('ajrSaaAkhira', 'أجره عن الساعة الأخيرة (ل.ل.)',
                              isLtr: true, kb: TextInputType.number),
                        ),
                        const SizedBox(height: 8),
                        tf('faqatSaaa', 'فقط (كتابةً)'),
                      ]),

                      // ── Responsible / Signature ───────────────────
                      section('إسم المسؤول وصفته'),
                      row2(
                        tf('ismMasool', 'اسم المسؤول'),
                        tf('sifatMasool', 'صفته'),
                      ),

                      // ── Beneficiary signature ─────────────────────
                      section('إفادة المضمون / صاحب الحق / الوكيل'),
                      tf('almuwaqiAdnah', 'الموقع أدناه (اسم المضمون / صاحب الحق / الوكيل)'),

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
                        backgroundColor: const Color(0xFF006064)),
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