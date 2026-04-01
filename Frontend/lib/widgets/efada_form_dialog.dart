import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/employee.dart';
import '../services/api_service.dart';
import 'dart:ui' as ui;

class EfadaFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const EfadaFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<EfadaFormDialog> createState() => _EfadaFormDialogState();
}

class _EfadaFormDialogState extends State<EfadaFormDialog> {
  late final Map<String, TextEditingController> c;

  // Absence / return checkboxes
  bool returned = false;
  bool notReturned = false;

  // Illness origin checkboxes
  bool workRelated = false;
  bool notWorkRelated = false;

  // Salary during illness checkboxes
  bool salaryStopped = false;
  bool salaryContinued = false;

  bool _saving = false, _generatingPdf = false;

  static String _fmtDt(DateTime? d) =>
      d != null ? DateFormat('yyyy-MM-dd').format(d) : '';

  static String _pick(List<String?> sources) {
    for (final s in sources) {
      if (s != null && s.trim().isNotEmpty) return s.trim();
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    c = {
      // ── Institution ──────────────────────────────────────────
      'institutionName':    TextEditingController(text: e.efadaInstitutionName ?? ''),
      'institutionNssfNum': TextEditingController(text: e.efadaInstitutionNssfNum ?? ''),
      // ── Employee ─────────────────────────────────────────────
      'employeeName':    TextEditingController(
          text: _pick([e.efadaEmployeeName, e.fullName])),
      'employeeNssfNum': TextEditingController(
          text: _pick([e.efadaEmployeeNssfNum, e.socialSecurityNumber])),
      'illnessDuration': TextEditingController(text: e.efadaIllnessDuration ?? ''),
      'distribution':    TextEditingController(text: e.efadaDistribution ?? ''),
      // ── 7 work months ─────────────────────────────────────────
      for (int i = 1; i <= 7; i++) ...{
        'month_$i':  TextEditingController(text: _efadaVal(e, 'month', i)),
        'days_$i':   TextEditingController(text: _efadaVal(e, 'days', i)),
        'from1_$i':  TextEditingController(text: _efadaVal(e, 'from1', i)),
        'to1_$i':    TextEditingController(text: _efadaVal(e, 'to1', i)),
        'from2_$i':  TextEditingController(text: _efadaVal(e, 'from2', i)),
        'to2_$i':    TextEditingController(text: _efadaVal(e, 'to2', i)),
        'from3_$i':  TextEditingController(text: _efadaVal(e, 'from3', i)),
        'to3_$i':    TextEditingController(text: _efadaVal(e, 'to3', i)),
      },
      // ── Total + 4 salary months ────────────────────────────
      'totalAmount':  TextEditingController(text: e.efadaTotalAmount ?? ''),
      for (int i = 1; i <= 4; i++) ...{
        'salMonth_$i': TextEditingController(text: _efadaSalVal(e, 'month', i)),
        'salPaid_$i':  TextEditingController(text: _efadaSalVal(e, 'paid', i)),
      },
      // ── Absence / return ──────────────────────────────────
      'absenceDate':      TextEditingController(text: e.efadaAbsenceDate ?? ''),
      'returnDate':       TextEditingController(text: e.efadaReturnDate ?? ''),
      'notReturnedDate':  TextEditingController(text: e.efadaNotReturnedDate ?? ''),
      // ── Signature ─────────────────────────────────────────
      'responsibleName': TextEditingController(
          text: _pick([e.efadaResponsibleName, e.fullName])),
      'city':      TextEditingController(text: e.efadaCity ?? ''),
      'signDate':  TextEditingController(
          text: _pick([e.efadaSignDate,
              DateFormat('yyyy-MM-dd').format(DateTime.now())])),
    };

    returned       = e.efadaReturned ?? false;
    notReturned    = e.efadaNotReturned ?? false;
    workRelated    = e.efadaWorkRelated ?? false;
    notWorkRelated = e.efadaNotWorkRelated ?? false;
    salaryStopped  = e.efadaSalaryStopped ?? false;
    salaryContinued= e.efadaSalaryContinued ?? false;

    _loadCompanyInfo();
  }

  // Helper to read per-row efada field from Employee
  static String _efadaVal(Employee e, String field, int row) {
    switch ('${field}_$row') {
      case 'month_1': return e.efadaMonth1 ?? '';
      case 'days_1':  return e.efadaDays1 ?? '';
      case 'from1_1': return e.efadaFrom1_1 ?? '';
      case 'to1_1':   return e.efadaTo1_1 ?? '';
      case 'from2_1': return e.efadaFrom2_1 ?? '';
      case 'to2_1':   return e.efadaTo2_1 ?? '';
      case 'from3_1': return e.efadaFrom3_1 ?? '';
      case 'to3_1':   return e.efadaTo3_1 ?? '';
      case 'month_2': return e.efadaMonth2 ?? '';
      case 'days_2':  return e.efadaDays2 ?? '';
      case 'from1_2': return e.efadaFrom1_2 ?? '';
      case 'to1_2':   return e.efadaTo1_2 ?? '';
      case 'from2_2': return e.efadaFrom2_2 ?? '';
      case 'to2_2':   return e.efadaTo2_2 ?? '';
      case 'from3_2': return e.efadaFrom3_2 ?? '';
      case 'to3_2':   return e.efadaTo3_2 ?? '';
      case 'month_3': return e.efadaMonth3 ?? '';
      case 'days_3':  return e.efadaDays3 ?? '';
      case 'from1_3': return e.efadaFrom1_3 ?? '';
      case 'to1_3':   return e.efadaTo1_3 ?? '';
      case 'from2_3': return e.efadaFrom2_3 ?? '';
      case 'to2_3':   return e.efadaTo2_3 ?? '';
      case 'from3_3': return e.efadaFrom3_3 ?? '';
      case 'to3_3':   return e.efadaTo3_3 ?? '';
      case 'month_4': return e.efadaMonth4 ?? '';
      case 'days_4':  return e.efadaDays4 ?? '';
      case 'from1_4': return e.efadaFrom1_4 ?? '';
      case 'to1_4':   return e.efadaTo1_4 ?? '';
      case 'from2_4': return e.efadaFrom2_4 ?? '';
      case 'to2_4':   return e.efadaTo2_4 ?? '';
      case 'from3_4': return e.efadaFrom3_4 ?? '';
      case 'to3_4':   return e.efadaTo3_4 ?? '';
      case 'month_5': return e.efadaMonth5 ?? '';
      case 'days_5':  return e.efadaDays5 ?? '';
      case 'from1_5': return e.efadaFrom1_5 ?? '';
      case 'to1_5':   return e.efadaTo1_5 ?? '';
      case 'from2_5': return e.efadaFrom2_5 ?? '';
      case 'to2_5':   return e.efadaTo2_5 ?? '';
      case 'from3_5': return e.efadaFrom3_5 ?? '';
      case 'to3_5':   return e.efadaTo3_5 ?? '';
      case 'month_6': return e.efadaMonth6 ?? '';
      case 'days_6':  return e.efadaDays6 ?? '';
      case 'from1_6': return e.efadaFrom1_6 ?? '';
      case 'to1_6':   return e.efadaTo1_6 ?? '';
      case 'from2_6': return e.efadaFrom2_6 ?? '';
      case 'to2_6':   return e.efadaTo2_6 ?? '';
      case 'from3_6': return e.efadaFrom3_6 ?? '';
      case 'to3_6':   return e.efadaTo3_6 ?? '';
      case 'month_7': return e.efadaMonth7 ?? '';
      case 'days_7':  return e.efadaDays7 ?? '';
      case 'from1_7': return e.efadaFrom1_7 ?? '';
      case 'to1_7':   return e.efadaTo1_7 ?? '';
      case 'from2_7': return e.efadaFrom2_7 ?? '';
      case 'to2_7':   return e.efadaTo2_7 ?? '';
      case 'from3_7': return e.efadaFrom3_7 ?? '';
      case 'to3_7':   return e.efadaTo3_7 ?? '';
      default: return '';
    }
  }

  static String _efadaSalVal(Employee e, String field, int row) {
    switch ('${field}_$row') {
      case 'month_1': return e.efadaSalMonth1 ?? '';
      case 'paid_1':  return e.efadaSalPaid1 ?? '';
      case 'month_2': return e.efadaSalMonth2 ?? '';
      case 'paid_2':  return e.efadaSalPaid2 ?? '';
      case 'month_3': return e.efadaSalMonth3 ?? '';
      case 'paid_3':  return e.efadaSalPaid3 ?? '';
      case 'month_4': return e.efadaSalMonth4 ?? '';
      case 'paid_4':  return e.efadaSalPaid4 ?? '';
      default: return '';
    }
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final company = await ApiService.getCompanyInfo();
      if (!mounted) return;
      final name = (company['company_name'] ?? '').toString().trim();
      final trade = (company['trade_name'] ?? '').toString().trim();
      final nssf = (company['social_security_number'] ?? '').toString().trim();
      if (c['institutionName']!.text.trim().isEmpty) {
        c['institutionName']!.text = trade.isNotEmpty ? trade : name;
      }
      if (nssf.isNotEmpty) c['institutionNssfNum']!.text = nssf;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final ctrl in c.values) ctrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildDataMap() {
    String? ne(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    final map = <String, dynamic>{
      'efada_institution_name':     ne(c['institutionName']!.text),
      'efada_institution_nssf_num': ne(c['institutionNssfNum']!.text),
      'efada_employee_name':        ne(c['employeeName']!.text),
      'efada_employee_nssf_num':    ne(c['employeeNssfNum']!.text),
      'efada_illness_duration':     ne(c['illnessDuration']!.text),
      'efada_distribution':         ne(c['distribution']!.text),
      'efada_total_amount':         ne(c['totalAmount']!.text),
      'efada_absence_date':         ne(c['absenceDate']!.text),
      'efada_returned':             returned,
      'efada_return_date':          ne(c['returnDate']!.text),
      'efada_not_returned':         notReturned,
      'efada_not_returned_date':    ne(c['notReturnedDate']!.text),
      'efada_work_related':         workRelated,
      'efada_not_work_related':     notWorkRelated,
      'efada_salary_stopped':       salaryStopped,
      'efada_salary_continued':     salaryContinued,
      'efada_responsible_name':     ne(c['responsibleName']!.text),
      'efada_city':                 ne(c['city']!.text),
      'efada_sign_date':            ne(c['signDate']!.text),
    };
    for (int i = 1; i <= 7; i++) {
      map['efada_month_$i']  = ne(c['month_$i']!.text);
      map['efada_days_$i']   = ne(c['days_$i']!.text);
      map['efada_from1_$i']  = ne(c['from1_$i']!.text);
      map['efada_to1_$i']    = ne(c['to1_$i']!.text);
      map['efada_from2_$i']  = ne(c['from2_$i']!.text);
      map['efada_to2_$i']    = ne(c['to2_$i']!.text);
      map['efada_from3_$i']  = ne(c['from3_$i']!.text);
      map['efada_to3_$i']    = ne(c['to3_$i']!.text);
    }
    for (int i = 1; i <= 4; i++) {
      map['efada_sal_month_$i'] = ne(c['salMonth_$i']!.text);
      map['efada_sal_paid_$i']  = ne(c['salPaid_$i']!.text);
    }
    return map;
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    try {
      await ApiService.saveR4Data(widget.employee.id!, _buildDataMap());
      widget.onDataChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم الحفظ بنجاح!'),
              backgroundColor: Color(0xFF00897B)),
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
      await ApiService.saveR4Data(widget.employee.id!, _buildDataMap());
      final pdfBytes = await _generateEfadaPdf();
      final fileName =
          'Efada_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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
              backgroundColor: const Color(0xFF00897B)),
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
  // PDF GENERATION — PdfPageFormat(1024, 1280) raw pixel coordinates
  //
  // Template layout (measured from efada_template_blank.png):
  //
  // ┌─ Header ───────────────────────────────────────────────────────┐
  // │  institutionNssfNum  boxes top-left   ~(56,  148)  w:220      │
  // │  institutionName     after "مؤسسة:"   ~(560, 148)  w:340      │
  // │  employeeNssfNum     boxes            ~(56,  196)  w:220      │
  // │  employeeName        after "الأجير:"  ~(560, 218)  w:340      │
  // │  illnessDuration     after "مدة"      ~(560, 252)  w:220      │
  // │  distribution        after "وفقاً"    ~(330, 252)  w:310      │
  // └────────────────────────────────────────────────────────────────┘
  // ┌─ Work months table (rows 1–7) ─────────────────────────────────┐
  // │  Row y-positions:  1=322, 2=348, 3=374, 4=400, 5=426, 6=452, 7=478
  // │  Columns (left→right on RTL form):
  // │    month  ~(862, y)  w:70
  // │    days   ~(770, y)  w:60
  // │    from3  ~(686, y)  w:50   to3  ~(638, y)  w:50
  // │    from2  ~(562, y)  w:50   to2  ~(514, y)  w:50
  // │    from1  ~(430, y)  w:50   to1  ~(374, y)  w:50
  // │  (Row 6 has "من/إلى" labels; row 7 has extra from/to labels)
  // └────────────────────────────────────────────────────────────────┘
  // ┌─ Salary section ────────────────────────────────────────────────┐
  // │  totalAmount   ~(730, 574)  w:120                               │
  // │  Row y-positions: 1=618, 2=640, 3=662, 4=684
  // │    salMonth_n  ~(820, y)   w:100
  // │    salPaid_n   ~(430, y)   w:120
  // └────────────────────────────────────────────────────────────────┘
  // ┌─ Absence / return (y ~730–800) ────────────────────────────────┐
  // │  absenceDate       ~(560, 730)  w:180                          │
  // │  ck returned       ~(880, 754)                                 │
  // │  returnDate        ~(560, 754)  w:180                          │
  // │  ck notReturned    ~(880, 778)                                 │
  // │  notReturnedDate   ~(560, 778)  w:180                          │
  // └────────────────────────────────────────────────────────────────┘
  // ┌─ Illness / salary during illness (y ~800–868) ─────────────────┐
  // │  ck notWorkRelated  ~(880, 800)                                │
  // │  ck workRelated     ~(880, 824)                                │
  // │  ck salaryStopped   ~(500, 800)                                │
  // │  ck salaryContinued ~(500, 824)                                │
  // └────────────────────────────────────────────────────────────────┘
  // ┌─ Signature (y ~910–950) ────────────────────────────────────────┐
  // │  responsibleName  ~(560, 910)  w:280                           │
  // │  city             ~(330, 936)  w:150                           │
  // │  signDate         ~(100, 936)  w:180                           │
  // └────────────────────────────────────────────────────────────────┘
  // ════════════════════════════════════════════════════════════════════
  Future<Uint8List> _generateEfadaPdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);
    final templateData =
        await rootBundle.load('assets/efada_template_blank.png');
    final templateImage =
        pw.MemoryImage(templateData.buffer.asUint8List());

    String v(String key) => c[key]?.text.trim() ?? '';

    final ts = pw.TextStyle(
        font: arabicFont, fontSize: 9, color: PdfColors.blue900);
    final tsChk = pw.TextStyle(
        font: arabicFont,
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900);

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
          child: pw.Text(text,
              style: style ?? ts,
              textDirection: pw.TextDirection.ltr,
              textAlign: pw.TextAlign.left,
              maxLines: 1),
        ),
      ));
    }

    void ck(double left, double top, bool val) {
      if (!val) return;
      o.add(pw.Positioned(
          left: left,
          top: top,
          child: pw.Text('X', style: tsChk)));
    }

    // ── Header ──────────────────────────────────────────────────────
l(66,  186, v('institutionNssfNum'), width: 230);
l(550, 184, v('institutionName'),    width: 470);
l(66,  248, v('employeeNssfNum'),    width: 230);
l(666, 238, v('employeeName'),       width: 470);
l(434, 284, v('illnessDuration'),    width: 160);
//l(56,  254, v('distribution'),       width: 290);

// ── Work months table ─────────────────────────────────────────
l(906, 434, v('month_1'),  width: 80);
l(714, 434, v('days_1'),   width: 70);
l(536, 434, v('from1_1'),  width: 50);
l(440, 434, v('to1_1'),    width: 50);
l(352, 434, v('from2_1'),  width: 50);
l(268, 434, v('to2_1'),    width: 50);
l(176, 434, v('from3_1'),  width: 50);
l(90, 434, v('to3_1'),    width: 50);

l(906, 470, v('month_2'),  width: 80);
l(714, 470, v('days_2'),   width: 70);
l(536, 470, v('from1_2'),  width: 50);
l(440, 470, v('to1_2'),    width: 50);
l(352, 470, v('from2_2'),  width: 50);
l(268, 470, v('to2_2'),    width: 50);
l(176, 470, v('from3_2'),  width: 50);
l(90, 470, v('to3_2'),    width: 50);

l(906, 506, v('month_3'),  width: 80);
l(714, 506, v('days_3'),   width: 70);
l(536, 506, v('from1_3'),  width: 50);
l(440, 506, v('to1_3'),    width: 50);
l(352, 506, v('from2_3'),  width: 50);
l(268, 506, v('to2_3'),    width: 50);
l(176, 506, v('from3_3'),  width: 50);
l(90, 506, v('to3_3'),    width: 50);


l(906, 542, v('month_4'),  width: 80);
l(714, 542, v('days_4'),   width: 70);
l(536, 542, v('from1_4'),  width: 50);
l(440, 542, v('to1_4'),    width: 50);
l(352, 542, v('from2_4'),  width: 50);
l(268, 542, v('to2_4'),    width: 50);
l(176, 542, v('from3_4'),  width: 50);
l(90, 542, v('to3_4'),    width: 50);

l(906, 573, v('month_5'),  width: 80);
l(714, 573, v('days_5'),   width: 70);
l(536, 573, v('from1_5'),  width: 50);
l(440, 573, v('to1_5'),    width: 50);
l(352, 573, v('from2_5'),  width: 50);
l(268, 573, v('to2_5'),    width: 50);
l(176, 573, v('from3_5'),  width: 50);
l(90, 573, v('to3_5'),    width: 50);

l(906, 609, v('month_6'),  width: 80);
l(714, 609, v('days_6'),   width: 70);
l(536, 609, v('from1_6'),  width: 50);
l(440, 609, v('to1_6'),    width: 50);
l(352, 609, v('from2_6'),  width: 50);
l(268, 609, v('to2_6'),    width: 50);
l(176, 609, v('from3_6'),  width: 50);
l(90, 609, v('to3_6'),    width: 50);


l(906, 640, v('month_7'),  width: 80);
l(714, 640, v('days_7'),   width: 70);
l(536, 640, v('from1_7'),  width: 50);
l(440, 640, v('to1_7'),    width: 50);
l(352, 640, v('from2_7'),  width: 50);
l(268, 640, v('to2_7'),    width: 50);
l(176, 640, v('from3_7'),  width: 50);
l(90, 640, v('to3_7'),    width: 50);

// ── Salary section ────────────────────────────────────────────
l(324,  722, v('totalAmount'),  width: 120);

l(660, 758, v('salMonth_1'),   width: 130);
l(278,  758, v('salPaid_1'),    width: 130);

l(660, 792, v('salMonth_2'),   width: 130);
l(278,  792, v('salPaid_2'),    width: 130);

l(660, 826, v('salMonth_3'),   width: 130);
l(278,  826, v('salPaid_3'),    width: 130);

l(660, 860, v('salMonth_4'),   width: 130);
l(278,  860, v('salPaid_4'),    width: 130);

// ── Absence / return ─────────────────────────────────────────
l(610, 902, v('absenceDate'),      width: 160);
ck(492, 912, returned);
l(184,  900, v('returnDate'),       width: 160);
ck(492, 948, notReturned);
l(170,  938, v('notReturnedDate'),  width: 160);

// ── Illness origin ────────────────────────────────────────────
ck(490, 984, notWorkRelated);
ck(492, 1018, workRelated);

// ── Salary during illness ─────────────────────────────────────
ck(912, 982, salaryStopped);
ck(912, 1020, salaryContinued);

// ── Signature ─────────────────────────────────────────────────
l(164,  1142, v('responsibleName'), width: 300);
l(388, 1142, v('city'),            width: 180);
l(294,  1142, v('signDate'),        width: 140);
    // ── Build PDF ─────────────────────────────────────────────────
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
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
    ));

    return Uint8List.fromList(await pdf.save());
  }

  // ════════════════════════════════════════════════════════════════════
  // DIALOG UI
  // ════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    const ltr = ui.TextDirection.ltr;
    const rtl = ui.TextDirection.rtl;

    InputDecoration dec(String label, {String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              child: Text(title,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF006064))),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ]),
        );

    Widget row2(Widget a, Widget b) => Row(children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ]);

    // One row of the work months table
    Widget monthRow(int n) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('الشهر $n',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: tf('month_$n', 'الشهر')),
                const SizedBox(width: 8),
                Expanded(child: tf('days_$n', 'عدد الأيام/الأسابيع', isLtr: true)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: tf('from1_$n', 'من ١', isLtr: true, hint: 'YYYY-MM-DD')),
                const SizedBox(width: 6),
                Expanded(child: tf('to1_$n',   'إلى ١', isLtr: true, hint: 'YYYY-MM-DD')),
                const SizedBox(width: 6),
                Expanded(child: tf('from2_$n', 'من ٢', isLtr: true, hint: 'YYYY-MM-DD')),
                const SizedBox(width: 6),
                Expanded(child: tf('to2_$n',   'إلى ٢', isLtr: true, hint: 'YYYY-MM-DD')),
                const SizedBox(width: 6),
                Expanded(child: tf('from3_$n', 'من ٣', isLtr: true, hint: 'YYYY-MM-DD')),
                const SizedBox(width: 6),
                Expanded(child: tf('to3_$n',   'إلى ٣', isLtr: true, hint: 'YYYY-MM-DD')),
              ]),
            ],
          ),
        );

    // One salary row
    Widget salRow(int n) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: row2(
            tf('salMonth_$n', 'شهر $n'),
            tf('salPaid_$n',  'الأجر المدفوع $n', isLtr: true,
                kb: TextInputType.number),
          ),
        );

    Widget ckRow(String label, bool val, VoidCallback onTap) =>
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Row(children: [
            Checkbox(
              value: val,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFF006064),
            ),
            Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13))),
          ]),
        );

    return Directionality(
      textDirection: rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 760, maxHeight: 880),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF006064), Color(0xFF00838F)]),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  const Icon(Icons.medical_information_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إفادة عمل',
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        Text(
                            'CNSS 2M — ${widget.employee.fullName}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ]),
              ),

              // ── Body ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Institution ───────────────────────────
                      section('المؤسسة'),
                      row2(
                        tf('institutionName',    'اسم المؤسسة'),
                        tf('institutionNssfNum', 'رقمها في الصندوق',
                            isLtr: true),
                      ),

                      // ── Employee ──────────────────────────────
                      section('الأجير'),
                      row2(
                        tf('employeeName',    'اسم الأجير'),
                        tf('employeeNssfNum', 'رقمه في الصندوق',
                            isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('illnessDuration', 'مدة المرض',
                            isLtr: true),
                        tf('distribution', 'وفقاً للتوزيع التالي'),
                      ),

                      // ── Work months ───────────────────────────
                      section('مدات العمل خلال الستة أشهر (١–٧)'),
                      for (int n = 1; n <= 7; n++) monthRow(n),

                      // ── Salary ────────────────────────────────
                      section('الأجور خلال الثلاثة أشهر الأخيرة'),
                      row2(
                        tf('totalAmount', 'المبلغ الإجمالي', isLtr: true,
                            kb: TextInputType.number),
                        Container(),
                      ),
                      const SizedBox(height: 8),
                      for (int n = 1; n <= 4; n++) salRow(n),

                      // ── Absence / return ──────────────────────
                      section('الانقطاع والعودة'),
                      tf('absenceDate', 'وانه قد انقطع عن العمل بتاريخ',
                          isLtr: true, hint: 'YYYY-MM-DD'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                              child: ckRow(
                                'عاد إلى العمل بتاريخ',
                                returned,
                                () => setState(() => returned = !returned),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: tf('returnDate', 'تاريخ العودة',
                                  isLtr: true, hint: 'YYYY-MM-DD'),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: ckRow(
                                'لم يعد إلى العمل حتى تاريخ',
                                notReturned,
                                () => setState(
                                    () => notReturned = !notReturned),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: tf('notReturnedDate',
                                  'التاريخ',
                                  isLtr: true,
                                  hint: 'YYYY-MM-DD'),
                            ),
                          ]),
                        ]),
                      ),

                      // ── Illness origin ────────────────────────
                      section('طارئ العمل والأجر'),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Column(children: [
                              ckRow(
                                'مرضه غير ناتج عن طارئ عمل',
                                notWorkRelated,
                                () => setState(
                                    () => notWorkRelated = !notWorkRelated),
                              ),
                              ckRow(
                                'مرضه ناتج عن طارئ عمل',
                                workRelated,
                                () => setState(
                                    () => workRelated = !workRelated),
                              ),
                            ]),
                          ),
                          Expanded(
                            child: Column(children: [
                              ckRow(
                                'أجره قد انقطع خلال فترة مرضه',
                                salaryStopped,
                                () => setState(
                                    () => salaryStopped = !salaryStopped),
                              ),
                              ckRow(
                                'أجره لم ينقطع خلال فترة مرضه',
                                salaryContinued,
                                () => setState(
                                    () => salaryContinued = !salaryContinued),
                              ),
                            ]),
                          ),
                        ]),
                      ),

                      // ── Signature ─────────────────────────────
                      section('التوقيع'),
                      row2(
                        tf('responsibleName', 'اسم المسؤول وختام المؤسسة'),
                        row2(
                          tf('city', 'في (المدينة)'),
                          tf('signDate', 'التاريخ',
                              isLtr: true, hint: 'YYYY-MM-DD'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ──────────────────────────────────────
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
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
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
                        backgroundColor: const Color(0xFFC62828)),
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