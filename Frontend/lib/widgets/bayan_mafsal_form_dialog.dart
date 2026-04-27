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

class BayanMafsalFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const BayanMafsalFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<BayanMafsalFormDialog> createState() => _BayanMafsalFormDialogState();
}

class _BayanMafsalFormDialogState extends State<BayanMafsalFormDialog> {
  late final Map<String, TextEditingController> c;

  bool _saving = false;
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    c = {
      // Header
      'ismAjir': TextEditingController(
          text: e.bayanIsmAjir ??
              '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim()),
      'raqmuhuFiSunduq': TextEditingController(
          text: e.bayanRaqmuhuFiSunduq ??
              e.employeeFundNumber ??
              e.socialSecurityNumber ?? ''),

      // Year 1
      'sana1': TextEditingController(text: e.bayanSana1 ?? ''),
      // Month rows year 1 — راتب أساسي / لواحق الراتب / مقبوضات أخرى / المجموع / ملاحظات
      for (int m = 1; m <= 12; m++) ...{
        'y1_basic_$m':   TextEditingController(text: e.bayanY1Basic(m) ?? ''),
        'y1_lawahiq_$m': TextEditingController(text: e.bayanY1Lawahiq(m) ?? ''),
        'y1_maqbudat_$m':TextEditingController(text: e.bayanY1Maqbudat(m) ?? ''),
        'y1_majmuu_$m':  TextEditingController(text: e.bayanY1Majmuu(m) ?? ''),
        'y1_mulahazat_$m':TextEditingController(text: e.bayanY1Mulahazat(m) ?? ''),
      },
      'y1_total_basic':    TextEditingController(text: e.bayanY1TotalBasic ?? ''),
      'y1_total_lawahiq':  TextEditingController(text: e.bayanY1TotalLawahiq ?? ''),
      'y1_total_maqbudat': TextEditingController(text: e.bayanY1TotalMaqbudat ?? ''),
      'y1_total_majmuu':   TextEditingController(text: e.bayanY1TotalMajmuu ?? ''),
      'y1_total_mulahazat':TextEditingController(text: e.bayanY1TotalMulahazat ?? ''),

      // Year 2
      'sana2': TextEditingController(text: e.bayanSana2 ?? ''),
      for (int m = 1; m <= 12; m++) ...{
        'y2_basic_$m':   TextEditingController(text: e.bayanY2Basic(m) ?? ''),
        'y2_lawahiq_$m': TextEditingController(text: e.bayanY2Lawahiq(m) ?? ''),
        'y2_maqbudat_$m':TextEditingController(text: e.bayanY2Maqbudat(m) ?? ''),
        'y2_majmuu_$m':  TextEditingController(text: e.bayanY2Majmuu(m) ?? ''),
        'y2_mulahazat_$m':TextEditingController(text: e.bayanY2Mulahazat(m) ?? ''),
      },
      'y2_total_basic':    TextEditingController(text: e.bayanY2TotalBasic ?? ''),
      'y2_total_lawahiq':  TextEditingController(text: e.bayanY2TotalLawahiq ?? ''),
      'y2_total_maqbudat': TextEditingController(text: e.bayanY2TotalMaqbudat ?? ''),
      'y2_total_majmuu':   TextEditingController(text: e.bayanY2TotalMajmuu ?? ''),
      'y2_total_mulahazat':TextEditingController(text: e.bayanY2TotalMulahazat ?? ''),

      // Signature block
      'ismMasool':   TextEditingController(text: e.bayanIsmMasool ?? ''),
      'sifatMasool': TextEditingController(text: e.bayanSifatMasool ?? ''),
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

    final Map<String, dynamic> data = {
      'bayan_ism_ajir':             ne(c['ismAjir']!.text),
      'bayan_raqmuhu_fi_sunduq':    ne(c['raqmuhuFiSunduq']!.text),
      'bayan_sana1':                ne(c['sana1']!.text),
      'bayan_sana2':                ne(c['sana2']!.text),
      'bayan_ism_masool':           ne(c['ismMasool']!.text),
      'bayan_sifat_masool':         ne(c['sifatMasool']!.text),
    };

    for (int m = 1; m <= 12; m++) {
      data['bayan_y1_basic_$m']    = ne(c['y1_basic_$m']!.text);
      data['bayan_y1_lawahiq_$m']  = ne(c['y1_lawahiq_$m']!.text);
      data['bayan_y1_maqbudat_$m'] = ne(c['y1_maqbudat_$m']!.text);
      data['bayan_y1_majmuu_$m']   = ne(c['y1_majmuu_$m']!.text);
      data['bayan_y1_mulahazat_$m']= ne(c['y1_mulahazat_$m']!.text);
      data['bayan_y2_basic_$m']    = ne(c['y2_basic_$m']!.text);
      data['bayan_y2_lawahiq_$m']  = ne(c['y2_lawahiq_$m']!.text);
      data['bayan_y2_maqbudat_$m'] = ne(c['y2_maqbudat_$m']!.text);
      data['bayan_y2_majmuu_$m']   = ne(c['y2_majmuu_$m']!.text);
      data['bayan_y2_mulahazat_$m']= ne(c['y2_mulahazat_$m']!.text);
    }

    data['bayan_y1_total_basic']     = ne(c['y1_total_basic']!.text);
    data['bayan_y1_total_lawahiq']   = ne(c['y1_total_lawahiq']!.text);
    data['bayan_y1_total_maqbudat']  = ne(c['y1_total_maqbudat']!.text);
    data['bayan_y1_total_majmuu']    = ne(c['y1_total_majmuu']!.text);
    data['bayan_y1_total_mulahazat'] = ne(c['y1_total_mulahazat']!.text);
    data['bayan_y2_total_basic']     = ne(c['y2_total_basic']!.text);
    data['bayan_y2_total_lawahiq']   = ne(c['y2_total_lawahiq']!.text);
    data['bayan_y2_total_maqbudat']  = ne(c['y2_total_maqbudat']!.text);
    data['bayan_y2_total_majmuu']    = ne(c['y2_total_majmuu']!.text);
    data['bayan_y2_total_mulahazat'] = ne(c['y2_total_mulahazat']!.text);

    return data;
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    try {
      await ApiService.saveBayanMafsalData(
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
      await ApiService.saveBayanMafsalData(
          widget.employee.id!, _buildDataMap());
      final pdfBytes = await _generatePdf();
      final fileName =
          'BayanMafsal_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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
        await rootBundle.load('assets/bayan_mafsal_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    // Template: 1024 x 1448 px (portrait A4-ish)
    const double imgW = 1024;
    const double imgH = 1448;

    String v(String key) => c[key]?.text.trim() ?? '';

    final ts = pw.TextStyle(
        font: arabicFont, fontSize: 9, color: PdfColors.blue900);
    final tsSmall = pw.TextStyle(
        font: arabicFont, fontSize: 8, color: PdfColors.blue900);

    final List<pw.Widget> o = [];

    // Helper: RTL text anchored to right edge of a box
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

    // Helper: LTR text anchored to left edge of a box
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

    // ── Coordinate system ──────────────────────────────────────────────────
    // Template is 1024 x 1448 px.
    // lRtl(right, top, ...) : right = right edge X of the text box
    //                         top   = Y from top of page
    //
    // Fixed X anchors (approximate — tune with your tool):
    //   Column: الشهر       right ~  65  width  40
    //   Column: الراتب الأساسي  right ~ 230  width 130
    //   Column: لواحق الراتب    right ~ 420  width 160
    //   Column: مقبوضات أخرى   right ~ 620  width 180
    //   Column: المجموع         right ~ 800  width 160
    //   Column: ملاحظات         right ~ 990  width 170
    //
    // Arabic month numbers (١–١٢ + المجموع):
    //   They are printed on the form template itself, so we only overlay
    //   the data cells.

    // ── Header ─────────────────────────────────────────────────────────────
    // "اسم الأجير :"  line
   // ══════════════════════════════════════════════════════════════════
    // FIXED X ANCHORS — right-edge of each column (adjust once here)
    // ══════════════════════════════════════════════════════════════════
    const double xNameR      = 758.0;   // اسم الأجير
    const double xFundR      = 228.0;   // رقمه في الصندوق
    const double xSanaR      = 522.0;   // سنة label (centered)
    const double xBasicR     = 866.0;   // الراتب الأساسي
    const double xLawahiqR   = 702.0;   // لواحق الراتب
    const double xMaqbudatR  = 544.0;   // مقبوضات أخرى
    const double xMajmuuR    = 398.0;   // المجموع
    const double xMulahazatR = 204.0;   // ملاحظات

    const double wName       = 340.0;
    const double wFund       = 200.0;
    const double wSana       = 100.0;
    const double wCol        = 130.0;   // numeric columns
    const double wMulahazat  = 170.0;   // ملاحظات wider

    // ══════════════════════════════════════════════════════════════════
    // HEADER
    // ══════════════════════════════════════════════════════════════════
    lRtl(xNameR, 122, v('ismAjir'),          width: wName);
    lRtl(xFundR, 122, v('raqmuhuFiSunduq'),  width: wFund);

    // ══════════════════════════════════════════════════════════════════
    // YEAR 1 — fill in each Y value below
    // ══════════════════════════════════════════════════════════════════
    lRtl(xSanaR, 188, v('sana1'), width: wSana);  // "سنة ____" label

    lRtl(xBasicR, 274, v('y1_basic_1'),    width: wCol); lRtl(xLawahiqR, 274, v('y1_lawahiq_1'),  width: wCol); lRtl(xMaqbudatR, 274, v('y1_maqbudat_1'), width: wCol); lRtl(xMajmuuR, 274, v('y1_majmuu_1'),   width: wCol); lRtl(xMulahazatR, 274, v('y1_mulahazat_1'), width: wMulahazat);
    lRtl(xBasicR, 304, v('y1_basic_2'),    width: wCol); lRtl(xLawahiqR, 304, v('y1_lawahiq_2'),  width: wCol); lRtl(xMaqbudatR, 304, v('y1_maqbudat_2'), width: wCol); lRtl(xMajmuuR, 304, v('y1_majmuu_2'),   width: wCol); lRtl(xMulahazatR, 304, v('y1_mulahazat_2'), width: wMulahazat);
    lRtl(xBasicR, 332, v('y1_basic_3'),    width: wCol); lRtl(xLawahiqR, 332, v('y1_lawahiq_3'),  width: wCol); lRtl(xMaqbudatR, 332, v('y1_maqbudat_3'), width: wCol); lRtl(xMajmuuR, 332, v('y1_majmuu_3'),   width: wCol); lRtl(xMulahazatR, 332, v('y1_mulahazat_3'), width: wMulahazat);
    lRtl(xBasicR, 362, v('y1_basic_4'),    width: wCol); lRtl(xLawahiqR, 362, v('y1_lawahiq_4'),  width: wCol); lRtl(xMaqbudatR, 362, v('y1_maqbudat_4'), width: wCol); lRtl(xMajmuuR, 362, v('y1_majmuu_4'),   width: wCol); lRtl(xMulahazatR, 362, v('y1_mulahazat_4'), width: wMulahazat);
    lRtl(xBasicR, 392, v('y1_basic_5'),    width: wCol); lRtl(xLawahiqR, 392, v('y1_lawahiq_5'),  width: wCol); lRtl(xMaqbudatR, 392, v('y1_maqbudat_5'), width: wCol); lRtl(xMajmuuR, 392, v('y1_majmuu_5'),   width: wCol); lRtl(xMulahazatR, 392, v('y1_mulahazat_5'), width: wMulahazat);
    lRtl(xBasicR, 422, v('y1_basic_6'),    width: wCol); lRtl(xLawahiqR, 422, v('y1_lawahiq_6'),  width: wCol); lRtl(xMaqbudatR, 422, v('y1_maqbudat_6'), width: wCol); lRtl(xMajmuuR, 422, v('y1_majmuu_6'),   width: wCol); lRtl(xMulahazatR, 422, v('y1_mulahazat_6'), width: wMulahazat);
    lRtl(xBasicR, 452, v('y1_basic_7'),    width: wCol); lRtl(xLawahiqR, 452, v('y1_lawahiq_7'),  width: wCol); lRtl(xMaqbudatR, 452, v('y1_maqbudat_7'), width: wCol); lRtl(xMajmuuR, 452, v('y1_majmuu_7'),   width: wCol); lRtl(xMulahazatR, 452, v('y1_mulahazat_7'), width: wMulahazat);
    lRtl(xBasicR, 482, v('y1_basic_8'),    width: wCol); lRtl(xLawahiqR, 482, v('y1_lawahiq_8'),  width: wCol); lRtl(xMaqbudatR, 482, v('y1_maqbudat_8'), width: wCol); lRtl(xMajmuuR, 482, v('y1_majmuu_8'),   width: wCol); lRtl(xMulahazatR, 482, v('y1_mulahazat_8'), width: wMulahazat);
    lRtl(xBasicR, 512, v('y1_basic_9'),    width: wCol); lRtl(xLawahiqR, 512, v('y1_lawahiq_9'),  width: wCol); lRtl(xMaqbudatR, 512, v('y1_maqbudat_9'), width: wCol); lRtl(xMajmuuR, 512, v('y1_majmuu_9'),   width: wCol); lRtl(xMulahazatR, 512, v('y1_mulahazat_9'), width: wMulahazat);
    lRtl(xBasicR, 542, v('y1_basic_10'),   width: wCol); lRtl(xLawahiqR, 542, v('y1_lawahiq_10'), width: wCol); lRtl(xMaqbudatR, 542, v('y1_maqbudat_10'),width: wCol); lRtl(xMajmuuR, 542, v('y1_majmuu_10'),  width: wCol); lRtl(xMulahazatR, 542, v('y1_mulahazat_10'),width: wMulahazat);
    lRtl(xBasicR, 572, v('y1_basic_11'),   width: wCol); lRtl(xLawahiqR, 572, v('y1_lawahiq_11'), width: wCol); lRtl(xMaqbudatR, 572, v('y1_maqbudat_11'),width: wCol); lRtl(xMajmuuR, 572, v('y1_majmuu_11'),  width: wCol); lRtl(xMulahazatR, 572, v('y1_mulahazat_11'),width: wMulahazat);
    lRtl(xBasicR, 602, v('y1_basic_12'),   width: wCol); lRtl(xLawahiqR, 602, v('y1_lawahiq_12'), width: wCol); lRtl(xMaqbudatR, 602, v('y1_maqbudat_12'),width: wCol); lRtl(xMajmuuR, 602, v('y1_majmuu_12'),  width: wCol); lRtl(xMulahazatR, 602, v('y1_mulahazat_12'),width: wMulahazat);
    // المجموع row — year 1
    lRtl(xBasicR, 632, v('y1_total_basic'),    width: wCol); lRtl(xLawahiqR, 632, v('y1_total_lawahiq'),  width: wCol); lRtl(xMaqbudatR, 632, v('y1_total_maqbudat'), width: wCol); lRtl(xMajmuuR, 632, v('y1_total_majmuu'),   width: wCol); lRtl(xMulahazatR, 632, v('y1_total_mulahazat'), width: wMulahazat);

    // ══════════════════════════════════════════════════════════════════
    // YEAR 2 — fill in each Y value below
    // ══════════════════════════════════════════════════════════════════
    lRtl(xSanaR, 672, v('sana2'), width: wSana);  // "سنة ____" label

    lRtl(xBasicR, 762, v('y2_basic_1'),    width: wCol); lRtl(xLawahiqR, 762, v('y2_lawahiq_1'),  width: wCol); lRtl(xMaqbudatR, 762, v('y2_maqbudat_1'), width: wCol); lRtl(xMajmuuR,762, v('y2_majmuu_1'),   width: wCol); lRtl(xMulahazatR, 762, v('y2_mulahazat_1'), width: wMulahazat);
    lRtl(xBasicR, 792, v('y2_basic_2'),    width: wCol); lRtl(xLawahiqR, 792, v('y2_lawahiq_2'),  width: wCol); lRtl(xMaqbudatR, 792, v('y2_maqbudat_2'), width: wCol); lRtl(xMajmuuR, 792, v('y2_majmuu_2'),   width: wCol); lRtl(xMulahazatR, 792, v('y2_mulahazat_2'), width: wMulahazat);
    lRtl(xBasicR, 822, v('y2_basic_3'),    width: wCol); lRtl(xLawahiqR, 822, v('y2_lawahiq_3'),  width: wCol); lRtl(xMaqbudatR, 822, v('y2_maqbudat_3'), width: wCol); lRtl(xMajmuuR, 822, v('y2_majmuu_3'),   width: wCol); lRtl(xMulahazatR, 822, v('y2_mulahazat_3'), width: wMulahazat);
    lRtl(xBasicR, 852, v('y2_basic_4'),    width: wCol); lRtl(xLawahiqR, 852, v('y2_lawahiq_4'),  width: wCol); lRtl(xMaqbudatR, 852, v('y2_maqbudat_4'), width: wCol); lRtl(xMajmuuR,  852, v('y2_majmuu_4'),   width: wCol); lRtl(xMulahazatR, 852, v('y2_mulahazat_4'), width: wMulahazat);
    lRtl(xBasicR, 882, v('y2_basic_5'),    width: wCol); lRtl(xLawahiqR, 882, v('y2_lawahiq_5'),  width: wCol); lRtl(xMaqbudatR, 882, v('y2_maqbudat_5'), width: wCol); lRtl(xMajmuuR, 882, v('y2_majmuu_5'),   width: wCol); lRtl(xMulahazatR, 882, v('y2_mulahazat_5'), width: wMulahazat);
    lRtl(xBasicR, 912, v('y2_basic_6'),    width: wCol); lRtl(xLawahiqR, 912, v('y2_lawahiq_6'),  width: wCol); lRtl(xMaqbudatR, 912, v('y2_maqbudat_6'), width: wCol); lRtl(xMajmuuR, 912, v('y2_majmuu_6'),   width: wCol); lRtl(xMulahazatR, 912, v('y2_mulahazat_6'), width: wMulahazat);
    lRtl(xBasicR, 942, v('y2_basic_7'),    width: wCol); lRtl(xLawahiqR, 942, v('y2_lawahiq_7'),  width: wCol); lRtl(xMaqbudatR, 942, v('y2_maqbudat_7'), width: wCol); lRtl(xMajmuuR, 942, v('y2_majmuu_7'),   width: wCol); lRtl(xMulahazatR, 942, v('y2_mulahazat_7'), width: wMulahazat);
    lRtl(xBasicR, 972, v('y2_basic_8'),    width: wCol); lRtl(xLawahiqR, 972, v('y2_lawahiq_8'),  width: wCol); lRtl(xMaqbudatR, 972, v('y2_maqbudat_8'), width: wCol); lRtl(xMajmuuR, 972, v('y2_majmuu_8'),   width: wCol); lRtl(xMulahazatR, 972, v('y2_mulahazat_8'), width: wMulahazat);
    lRtl(xBasicR, 1002, v('y2_basic_9'),    width: wCol); lRtl(xLawahiqR, 1002, v('y2_lawahiq_9'),  width: wCol); lRtl(xMaqbudatR, 1002, v('y2_maqbudat_9'), width: wCol); lRtl(xMajmuuR, 1002, v('y2_majmuu_9'),   width: wCol); lRtl(xMulahazatR, 1002, v('y2_mulahazat_9'), width: wMulahazat);
    lRtl(xBasicR, 1032, v('y2_basic_10'),   width: wCol); lRtl(xLawahiqR, 1032, v('y2_lawahiq_10'), width: wCol); lRtl(xMaqbudatR, 1032, v('y2_maqbudat_10'),width: wCol); lRtl(xMajmuuR, 1032, v('y2_majmuu_10'),  width: wCol); lRtl(xMulahazatR, 1032, v('y2_mulahazat_10'),width: wMulahazat);
    lRtl(xBasicR, 1062, v('y2_basic_11'),   width: wCol); lRtl(xLawahiqR, 1062, v('y2_lawahiq_11'), width: wCol); lRtl(xMaqbudatR, 1062, v('y2_maqbudat_11'),width: wCol); lRtl(xMajmuuR, 1062, v('y2_majmuu_11'),  width: wCol); lRtl(xMulahazatR, 1062, v('y2_mulahazat_11'),width: wMulahazat);
    lRtl(xBasicR, 1092, v('y2_basic_12'),   width: wCol); lRtl(xLawahiqR, 1092, v('y2_lawahiq_12'), width: wCol); lRtl(xMaqbudatR, 1092, v('y2_maqbudat_12'),width: wCol); lRtl(xMajmuuR, 1092, v('y2_majmuu_12'),  width: wCol); lRtl(xMulahazatR, 1092, v('y2_mulahazat_12'),width: wMulahazat);
    // المجموع row — year 2
    lRtl(xBasicR, 1122, v('y2_total_basic'),    width: wCol); lRtl(xLawahiqR, 1122, v('y2_total_lawahiq'),  width: wCol); lRtl(xMaqbudatR, 1122, v('y2_total_maqbudat'), width: wCol); lRtl(xMajmuuR, 1122, v('y2_total_majmuu'),   width: wCol); lRtl(xMulahazatR, 1122, v('y2_total_mulahazat'), width: wMulahazat);

    // ══════════════════════════════════════════════════════════════════
    // SIGNATURE BLOCK
    // ══════════════════════════════════════════════════════════════════
    lRtl(900, 1200, v('ismMasool'),   width: 200);
    lRtl(660, 1200, v('sifatMasool'), width: 200);

    // ── Build PDF ────────────────────────────────────────────────────────────
    final pdf = pw.Document();
pdf.addPage(
  pw.Page(
    pageFormat: PdfPageFormat(imgW, imgH),
    margin: pw.EdgeInsets.zero,
    build: (ctx) => pw.FullPage(
      ignoreMargins: true,
      child: pw.Stack(children: [
        pw.Positioned(          // ← was pw.Positioned.fill(child: pw.Positioned(...))
          left: 0,
          top: 0,
          child: pw.Image(templateImage, width: imgW, height: imgH),
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

    // 5-column row for a single month
    Widget monthRow(String yearPrefix, int month, String monthLabel) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            // Month label
            SizedBox(
              width: 40,
              child: Text(
                monthLabel,
                textDirection: rtl,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_basic_$month'],
                textDirection: ltr,
                keyboardType: TextInputType.number,
                decoration: dec('الراتب الأساسي'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_lawahiq_$month'],
                textDirection: ltr,
                keyboardType: TextInputType.number,
                decoration: dec('لواحق الراتب'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_maqbudat_$month'],
                textDirection: ltr,
                keyboardType: TextInputType.number,
                decoration: dec('مقبوضات أخرى'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_majmuu_$month'],
                textDirection: ltr,
                keyboardType: TextInputType.number,
                decoration: dec('المجموع'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_mulahazat_$month'],
                textDirection: rtl,
                decoration: dec('ملاحظات'),
              ),
            ),
          ],
        ),
      );
    }

    // Total row
    Widget totalRow(String yearPrefix) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            const SizedBox(
              width: 40,
              child: Text(
                'المجموع',
                textDirection: rtl,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_total_basic'],
                textDirection: ltr,
                keyboardType: TextInputType.number,
                decoration: dec('إجمالي الراتب الأساسي'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_total_lawahiq'],
                textDirection: ltr,
                keyboardType: TextInputType.number,
                decoration: dec('إجمالي لواحق الراتب'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_total_maqbudat'],
                textDirection: ltr,
                keyboardType: TextInputType.number,
                decoration: dec('إجمالي مقبوضات أخرى'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_total_majmuu'],
                textDirection: ltr,
                keyboardType: TextInputType.number,
                decoration: dec('إجمالي المجموع'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c['${yearPrefix}_total_mulahazat'],
                textDirection: rtl,
                decoration: dec('ملاحظات'),
              ),
            ),
          ],
        ),
      );
    }

    // Column headers label row
    Widget colHeaders() => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: const [
              SizedBox(width: 40),
              SizedBox(width: 6),
              Expanded(
                child: Text('الراتب الأساسي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text('لواحق الراتب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text('مقبوضات أخرى',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text('المجموع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text('ملاحظات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

    final arabicMonths = [
      '١', '٢', '٣', '٤', '٥', '٦',
      '٧', '٨', '٩', '١٠', '١١', '١٢',
    ];

    return Directionality(
      textDirection: rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 860),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────
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
                  const Icon(Icons.table_chart_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بيان مفصّل بأجور السنتين الأخيرتين',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'قبل ترك الأجير لعمله — ${widget.employee.fullName}',
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
                      // ── Employee info ──────────────────────────
                      section('بيانات الأجير'),
                      row2(
                        tf('ismAjir', 'اسم الأجير'),
                        tf('raqmuhuFiSunduq', 'رقمه في الصندوق',
                            isLtr: true),
                      ),

                      // ── Year 1 ────────────────────────────────
                      section('السنة الأولى'),
                      tf('sana1', 'السنة', isLtr: true, hint: 'مثال: 2023'),
                      const SizedBox(height: 12),
                      colHeaders(),
                      for (int m = 1; m <= 12; m++)
                        monthRow('y1', m, arabicMonths[m - 1]),
                      totalRow('y1'),

                      // ── Year 2 ────────────────────────────────
                      section('السنة الثانية'),
                      tf('sana2', 'السنة', isLtr: true, hint: 'مثال: 2024'),
                      const SizedBox(height: 12),
                      colHeaders(),
                      for (int m = 1; m <= 12; m++)
                        monthRow('y2', m, arabicMonths[m - 1]),
                      totalRow('y2'),

                      // ── Signature ─────────────────────────────
                      section('اسم المسؤول وصفته'),
                      row2(
                        tf('ismMasool', 'اسم المسؤول'),
                        tf('sifatMasool', 'صفته'),
                      ),

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