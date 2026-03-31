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

class TasreehZawjaFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const TasreehZawjaFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<TasreehZawjaFormDialog> createState() => _TasreehZawjaFormDialogState();
}

class _TasreehZawjaFormDialogState extends State<TasreehZawjaFormDialog> {
  late final Map<String, TextEditingController> c;

  /// true  → spouse has paid work (تزاول عملاً مأجوراً)
  /// false → spouse does NOT work (لا تزاول عملاً مأجوراً)
  bool spouseHasWork = false;
  bool _saving = false, _generatingPdf = false;

  String _fmtDt(DateTime? d) =>
      d != null ? DateFormat('yyyy-MM-dd').format(d) : '';

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    c = {
      // ── Subscriber (المضمون) ──────────────────────────────────
      'subscriberRegNum':
          TextEditingController(text: e.ministryRegistrationNumber ?? ''),
      'subscriberName':
          TextEditingController(
              text: '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim()),
      'subscriberMother':
          TextEditingController(text: e.motherName ?? ''),
      'subscriberFather':
          TextEditingController(text: e.fatherName ?? ''),
      'registerNum':
          TextEditingController(text: e.registerNumber ?? ''),
      'companyName':
          TextEditingController(text: 'شركة ابولا ديليس ش.م.ل'),
      'companyRegNum':
          TextEditingController(text: e.ministryRegistrationNumber ?? ''),
      'address':
          TextEditingController(
              text: [e.area, e.street, e.building]
                  .where((s) => s != null && s.isNotEmpty)
                  .join(', ')),
      // ── Spouse (الزوجة) ───────────────────────────────────────
      'spouseFullName':
          TextEditingController(text: e.spouseName ?? ''),
      'spouseDob':
          TextEditingController(text: _fmtDt(e.spouseDateOfBirth)),
      'spouseWorkType':
          TextEditingController(text: e.spouseWorkDetails ?? ''),
      // ── Date ─────────────────────────────────────────────────
      'declarationDate':
          TextEditingController(
              text: DateFormat('yyyy-MM-dd').format(DateTime.now())),
    };

    spouseHasWork = widget.employee.spouseWorks ?? false;
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
      'tasreeh_subscriber_reg_num': ne(c['subscriberRegNum']!.text),
      'tasreeh_subscriber_name': ne(c['subscriberName']!.text),
      'tasreeh_subscriber_mother': ne(c['subscriberMother']!.text),
      'tasreeh_subscriber_father': ne(c['subscriberFather']!.text),
      'tasreeh_register_num': ne(c['registerNum']!.text),
      'tasreeh_company_name': ne(c['companyName']!.text),
      'tasreeh_company_reg_num': ne(c['companyRegNum']!.text),
      'tasreeh_address': ne(c['address']!.text),
      'tasreeh_spouse_full_name': ne(c['spouseFullName']!.text),
      'tasreeh_spouse_dob': ne(c['spouseDob']!.text),
      'tasreeh_spouse_has_work': spouseHasWork,
      'tasreeh_spouse_work_type': ne(c['spouseWorkType']!.text),
      'tasreeh_declaration_date': ne(c['declarationDate']!.text),
    };
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
      await ApiService.saveR4Data(widget.employee.id!, _buildDataMap());
      final pdfBytes = await _generateTasreehPdf();
      final fileName =
          'TasreehZawja_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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
  Future<Uint8List> _generateTasreehPdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData =
        await rootBundle.load('assets/tasryh_zawjaa_template_blank.png');
    final templateImage =
        pw.MemoryImage(templateData.buffer.asUint8List());

    String v(String key) => c[key]?.text.trim() ?? '';

    // Split yyyy-MM-dd → [day, month, year]
    List<String> pd(String date) {
      if (date.isEmpty) return ['', '', ''];
      final p = date.split('-');
      return p.length == 3 ? [p[2], p[1], p[0]] : ['', '', ''];
    }

    final spDob = pd(v('spouseDob'));
    final declDate = pd(v('declarationDate'));

    final ts = pw.TextStyle(
        font: arabicFont, fontSize: 9, color: PdfColors.blue900);
    final tsChk = pw.TextStyle(
        font: arabicFont,
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900);

    final List<pw.Widget> o = [];

    // ── Same helper as e3lam ─────────────────────────────────────
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

    void ck(double left, double top, bool val) {
      if (!val) return;
      o.add(pw.Positioned(
        left: left,
        top: top,
        child: pw.Text('X', style: tsChk),
      ));
    }

    // ── Section: المضمون ──────────────────────────────────
    // "أنا المضمون الموقع أدناه المسجل في الصندوق تحت الرقم"
    l(342, 320, v('subscriberRegNum'), width: 230);  // registration number box (left side)

    // الاسم والشهرة / اسم الأم وشهرتها
    l(728, 362, v('subscriberName'), width: 300);       // الاسم والشهرة (right)
    l(330, 362, v('subscriberMother'), width: 260);     // اسم الأم وشهرتها (mid)

    // اسم الأب / رقم السجل
    l(750, 396, v('subscriberFather'), width: 300);     // اسم الأب
    l(354, 396, v('registerNum'), width: 180);          // رقم السجل

    // العامل في مؤسسة / رقمها
    l(702, 436, v('companyName'), width: 560);          // اسم المؤسسة
    l(292, 440, v('companyRegNum'), width: 230);        // رقم المؤسسة (left box)

    // عنوانها
    l(636, 494, v('address'), width: 760);             // عنوانها

    // ── Section: الزوجة ──────────────────────────────────
    // الاسم الثلاثي للزوجة + تاريخ الولادة
    l(742, 620, v('spouseFullName'), width: 460);       // الاسم الثلاثي

    // تاريخ الولادة: boxes are [day | month | year] on the LEFT side
    l(342, 626, spDob[0], width: 70);   // اليوم
    l(252, 626, spDob[1], width: 70);   // الشهر
    l(162, 626,  spDob[2], width: 90);   // السنة

    // checkbox (2) تزاول عملاً مأجوراً  →  left small square
    ck(930, 686, spouseHasWork);
    // work type text beside checkbox (2)
    l(570, 666, v('spouseWorkType'), width: 430);

    // checkbox (3) لا تزاول عملاً مأجوراً وتعيش معي تحت سقف واحد
    ck(928, 738, !spouseHasWork);

    // ── Declaration date ─────────────────────────────────
    // التاريخ: day / month / year
    l(700, 826, declDate[0], width: 50); // day
    l(650, 826, declDate[1], width: 50); // month
    l(580, 826, declDate[2], width: 70); // year

    // ── Build PDF ─────────────────────────────────────────────────
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(1024, 1280),
        margin: pw.EdgeInsets.zero,
        build: (ctx) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(children: [
              pw.Positioned.fill(
                child: pw.Positioned(
                  left: 0,
                  top: 0,
                  child:
                      pw.Image(templateImage, width: 1024, height: 1280),
                ),
              ),
              ...o,
            ]),
          );
        },
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
        {bool isLtr = false, TextInputType? kb, String? hint}) {
      return TextField(
        controller: c[key],
        textDirection: isLtr ? ltr : rtl,
        decoration: dec(label, hint: hint),
        keyboardType: kb,
      );
    }

    Widget section(String title) {
      return Padding(
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
                color: const Color(0xFF1B5E20),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ]),
      );
    }

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
              // ── Header ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  const Icon(Icons.family_restroom_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تصريح عن الزوجة',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'CNSS 485 A — ${widget.employee.fullName}',
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

              // ── Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── المضمون ────────────────────────────────
                      section('معلومات عن المضمون'),
                      row2(
                        tf('subscriberName', 'الاسم والشهرة'),
                        tf('subscriberMother', 'اسم الأم وشهرتها'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('subscriberFather', 'اسم الأب'),
                        tf('registerNum', 'رقم السجل', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('subscriberRegNum',
                            'المسجل في الصندوق تحت الرقم',
                            isLtr: true),
                        Container(),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('companyName', 'العامل في مؤسسة'),
                        tf('companyRegNum', 'رقم المؤسسة', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      tf('address', 'عنوانها'),

                      // ── الزوجة ─────────────────────────────────
                      section('معلومات عن الزوجة'),
                      row2(
                        tf('spouseFullName', 'الاسم الثلاثي للزوجة'),
                        tf('spouseDob', 'تاريخ الولادة',
                            isLtr: true, hint: 'YYYY-MM-DD'),
                      ),
                      const SizedBox(height: 16),

                      // Work-status checkboxes
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Checkbox(
                                value: spouseHasWork,
                                onChanged: (v) => setState(
                                    () => spouseHasWork = v ?? false),
                                activeColor: const Color(0xFF1B5E20),
                              ),
                              const Expanded(
                                child: Text(
                                    '(٢)  تزاول عملاً مأجوراً',
                                    style: TextStyle(fontSize: 14)),
                              ),
                            ]),
                            if (spouseHasWork)
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 48, bottom: 8),
                                child:
                                    tf('spouseWorkType', 'نوع العمل'),
                              ),
                            Row(children: [
                              Checkbox(
                                value: !spouseHasWork,
                                onChanged: (v) => setState(
                                    () =>
                                        spouseHasWork = !(v ?? true)),
                                activeColor: const Color(0xFF1B5E20),
                              ),
                              const Expanded(
                                child: Text(
                                  '(٣)  لا تزاول عملاً مأجوراً وتعيش معي تحت سقف واحد',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),

                      // ── التاريخ ────────────────────────────────
                      section('التاريخ'),
                      row2(
                        tf('declarationDate', 'تاريخ التصريح',
                            isLtr: true, hint: 'YYYY-MM-DD'),
                        Container(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade200)),
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
                            child: CircularProgressIndicator(
                                strokeWidth: 2))
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
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Icon(Icons.picture_as_pdf_rounded,
                            size: 18),
                    label: Text(_generatingPdf
                        ? 'جاري...'
                        : 'حفظ + إنشاء PDF'),
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