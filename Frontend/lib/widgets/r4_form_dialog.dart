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

class R4FormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const R4FormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<R4FormDialog> createState() => _R4FormDialogState();
}

class _R4FormDialogState extends State<R4FormDialog> {
  late final Map<String, TextEditingController> c;
  String? genderVal, maritalVal, wageTypeVal;
  bool hasFinNum = false, spouseWorks = false;
  bool _saving = false, _generatingPdf = false;

  String _fmtDt(DateTime? d) => d != null ? DateFormat('yyyy-MM-dd').format(d) : '';

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    c = {
      'firstName': TextEditingController(text: e.firstName ?? ''),
      'lastName': TextEditingController(text: e.lastName ?? ''),
      'fatherName': TextEditingController(text: e.fatherName ?? ''),
      'motherName': TextEditingController(text: e.motherName ?? ''),
      'nationality': TextEditingController(text: e.nationality ?? ''),
      'placeOfBirth': TextEditingController(text: e.placeOfBirth ?? ''),
      'dob': TextEditingController(text: _fmtDt(e.dateOfBirth)),
      'registerNum': TextEditingController(text: e.registerNumber ?? ''),
      'registerPlace': TextEditingController(text: e.registerPlace ?? ''),
      'idCard': TextEditingController(text: e.idCardNumber ?? ''),
      'children': TextEditingController(text: e.numberOfChildren?.toString() ?? ''),
      'finNum': TextEditingController(text: e.personalFinancialNumber ?? ''),
      'ministryReg': TextEditingController(text: e.ministryRegistrationNumber ?? ''),
      'phone': TextEditingController(text: e.phone ?? ''),
      'email': TextEditingController(text: e.email ?? ''),
      'spouseName': TextEditingController(text: e.spouseName ?? ''),
      'spouseMaiden': TextEditingController(text: e.spouseMaidenName ?? ''),
      'spouseFather': TextEditingController(text: e.spouseFatherName ?? ''),
      'spouseMother': TextEditingController(text: e.spouseMotherName ?? ''),
      'spouseNat': TextEditingController(text: e.spouseNationality ?? ''),
      'spousePob': TextEditingController(text: e.spousePlaceOfBirth ?? ''),
      'spouseDob': TextEditingController(text: _fmtDt(e.spouseDateOfBirth)),
      'spouseId': TextEditingController(text: e.spouseIdCardNumber ?? ''),
      'spouseRegNum': TextEditingController(text: e.spouseRegisterNumber ?? ''),
      'spouseRegPlace': TextEditingController(text: e.spouseRegisterPlace ?? ''),
      'spouseWorkDetails': TextEditingController(text: e.spouseWorkDetails ?? ''),
      'spouseMinReg': TextEditingController(text: e.spouseRegistrationNumber ?? ''),
      'spouseRegNum2': TextEditingController(text: e.spouseRegistrationNumber2 ?? ''),
      // NEW FIELDS for spouse work sector & company
      'spouseWorkSector': TextEditingController(text: e.spouseWorkSector ?? ''),
      'spouseWorkCompany': TextEditingController(text: e.spouseWorkCompany ?? ''),
      'gov': TextEditingController(text: e.governorate ?? ''),
      'district': TextEditingController(text: e.district ?? ''),
      'area': TextEditingController(text: e.area ?? ''),
      'neighborhood': TextEditingController(text: e.neighborhood ?? ''),
      'street': TextEditingController(text: e.street ?? ''),
      'building': TextEditingController(text: e.building ?? ''),
      'floor': TextEditingController(text: e.floor ?? ''),
      'property': TextEditingController(text: e.propertyNumber ?? ''),
      'poBoxNumber': TextEditingController(text: e.poBoxNumber ?? ''),
  'poBoxArea': TextEditingController(text: e.poBoxArea ?? ''),
      'fax': TextEditingController(text: e.fax ?? ''),
    };
    genderVal = e.gender;
    maritalVal = e.maritalStatus;
    wageTypeVal = e.wageType;               // load existing wage type
    hasFinNum = e.hasFinancialNumber ?? false;
    spouseWorks = e.spouseWorks ?? false;
  }

  @override
  void dispose() {
    for (final ctrl in c.values) ctrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildDataMap() {
    String? ne(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    int? ni(String? v) => (v == null || v.trim().isEmpty) ? null : int.tryParse(v.trim());
    return {
      'first_name': ne(c['firstName']!.text),
      'last_name': ne(c['lastName']!.text),
      'father_name': ne(c['fatherName']!.text),
      'mother_name': ne(c['motherName']!.text),
      'gender': genderVal,
      'nationality': ne(c['nationality']!.text),
      'place_of_birth': ne(c['placeOfBirth']!.text),
      'date_of_birth': ne(c['dob']!.text),
      'register_number': ne(c['registerNum']!.text),
      'register_place': ne(c['registerPlace']!.text),
      'id_card_number': ne(c['idCard']!.text),
      'marital_status': maritalVal,
      'number_of_children': ni(c['children']!.text),
      'has_financial_number': hasFinNum,
      'personal_financial_number': ne(c['finNum']!.text),
      'ministry_registration_number': ne(c['ministryReg']!.text),
      'phone': ne(c['phone']!.text),
      'email': ne(c['email']!.text),
      'spouse_name': ne(c['spouseName']!.text),
      'spouse_maiden_name': ne(c['spouseMaiden']!.text),
      'spouse_father_name': ne(c['spouseFather']!.text),
      'spouse_mother_name': ne(c['spouseMother']!.text),
      'spouse_nationality': ne(c['spouseNat']!.text),
      'spouse_place_of_birth': ne(c['spousePob']!.text),
      'spouse_date_of_birth': ne(c['spouseDob']!.text),
      'spouse_id_card_number': ne(c['spouseId']!.text),
      'spouse_register_number': ne(c['spouseRegNum']!.text),
      'spouse_register_place': ne(c['spouseRegPlace']!.text),
      'spouse_works': spouseWorks,
      'spouse_work_details': ne(c['spouseWorkDetails']!.text),
      'spouse_registration_number': ne(c['spouseMinReg']!.text),
      // NEW fields
      'po_box_number': ne(c['poBoxNumber']!.text),
    'po_box_area': ne(c['poBoxArea']!.text),
      'spouse_registration_number_2': ne(c['spouseRegNum2']!.text),
      'spouse_work_sector': ne(c['spouseWorkSector']!.text),
      'spouse_work_company': ne(c['spouseWorkCompany']!.text),
      'governorate': ne(c['gov']!.text),
      'district': ne(c['district']!.text),
      'area': ne(c['area']!.text),
      'neighborhood': ne(c['neighborhood']!.text),
      'street': ne(c['street']!.text),
      'building': ne(c['building']!.text),
      'floor': ne(c['floor']!.text),
      'property_number': ne(c['property']!.text),
      'fax': ne(c['fax']!.text),
      'wage_type': wageTypeVal,   // ✅ include wage type
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
            content: Text('R4 data saved!'),
            backgroundColor: Color(0xFF00897B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _saving = false);
  }

  Future<void> _saveAndGeneratePdf() async {
    setState(() => _generatingPdf = true);
    try {
      await ApiService.saveR4Data(widget.employee.id!, _buildDataMap());
      final pdfBytes = await _generateR4Pdf();
      final fileName =
          'R4_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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
            content: Text('PDF "$fileName" saved!'),
            backgroundColor: const Color(0xFF00897B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _generatingPdf = false);
  }

  // ══════════════════════════════════════════════════════════
  // PDF GENERATION
  // ══════════════════════════════════════════════════════════
  Future<Uint8List> _generateR4Pdf() async {
    final fontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);
    final templateData = await rootBundle.load('assets/r4_template_blank.png'); // or .jpeg
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    String v(String key) => c[key]?.text ?? '';

    List<String> pd(String date) {
      if (date.isEmpty) return ['', '', ''];
      final p = date.split('-');
      return p.length == 3 ? [p[2], p[1], p[0]] : ['', '', ''];
    }
    final dob = pd(v('dob'));
    final spDob = pd(v('spouseDob'));
    final today = pd(DateFormat('yyyy-MM-dd').format(DateTime.now()));

    // Adjust these factors to match your actual template dimensions
    const sx = 595.28 / 1024.0;  // PDF width / image width
    const sy = 841.89 / 1280.0;  // PDF height / image height

    final ts = pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.blue900);
    final tsChk = pw.TextStyle(font: arabicFont, fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);

    final List<pw.Widget> o = [];

    void r(double px, double py, String text) {
      if (text.isEmpty) return;
      o.add(pw.Positioned(
        left: px * sx,
        top: py * sy,
        child: pw.Text(text, style: ts, textDirection: pw.TextDirection.rtl)
      ));
    }
    
    void l(double px, double py, String text) {
      if (text.isEmpty) return;
      o.add(pw.Positioned(
        left: px * sx,
        top: py * sy,
        child: pw.Text(text, style: ts, textDirection: pw.TextDirection.ltr)
      ));
    }
    
    void ck(double px, double py, bool val) {
      if (!val) return;
      o.add(pw.Positioned(
        left: px * sx,
        top: py * sy,
        child: pw.Text('X', style: tsChk)
      ));
    }

    // ─── COMPANY INFO ──────────────────────────────────────
    r(650, 141, 'شركة ابولا ديليس ش.م.ل');
    r(650, 180, 'Abola Delices sal');
    l(26, 178, v('ministryReg'));

    // ─── تعريف SECTION ────────────────────────────────────
    ck(490, 256, hasFinNum);      // نعم
    ck(412, 256, !hasFinNum);     // كلا
    l(25, 245, v('finNum'));

    r(680, 275, v('firstName'));
    r(300, 275, v('lastName'));

    r(680, 315, v('fatherName'));
    r(56, 326, v('motherName'));

    ck(860, 370, genderVal == 'ذكر');
    ck(702, 355, genderVal == 'أنثى');
    r(286, 368, v('nationality'));

    r(700, 404, v('placeOfBirth'));
    l(352, 402, dob[0]); // day
    l(280, 402, dob[1]); // month
    l(200, 402, dob[2]); // year

    r(800, 454, v('registerNum'));
    r(470, 454, v('registerPlace'));
    l(98, 454, v('idCard'));

    ck(810, 500, maritalVal == 'أعزب');
    ck(712, 500, maritalVal == 'متزوج');
    ck(622, 500, maritalVal == 'أرمل');
    ck(546, 500, maritalVal == 'مطلق');

    // ✅ Use wageTypeVal instead of widget.employee.wageType
    ck(838, 550, wageTypeVal == 'full time');
    ck(748, 550, wageTypeVal == 'daily');
    ck(664, 550, wageTypeVal == 'hourly');

    l(512, 586, v('children'));

    // ─── SPOUSE ────────────────────────────────────────────
    r(680, 640, v('spouseName'));
    r(300, 640, v('spouseMaiden'));

    r(680, 680, v('spouseFather'));
    r(186, 680, v('spouseMother'));

    r(680, 720, v('spouseNat'));
    r(300, 720, v('spousePob'));

    l(804, 760, spDob[0]);
    l(736, 760, spDob[1]);
    l(658, 760, spDob[2]);
    l(266, 760, v('spouseId'));

    r(756, 800, v('spouseRegNum'));
    r(302, 782, v('spouseRegPlace'));

    // ١١. هل يعمل
    ck(694, 830, spouseWorks);
    ck(622, 830, !spouseWorks);

    // NEW: two lines for work details (sector and company name)
    l(468, 908, v('spouseWorkCompany')); // أ. اسم الشركة
l(524, 952, v('spouseWorkSector'));  // ب. اسم الإدارة  // ب - إسم الشركة
    // Optional: keep old details field if still needed
    // l(274, 890, v('spouseWorkDetails'));

    // رقم التسجيل الشخصي (وزارة المالية) – spouseMinReg
    l(618, 852, v('spouseMinReg')); // adjust Y as needed
      // Second registration number (spouseRegistrationNumber2)
    l(16, 902, v('spouseRegNum2'));   // same left alignment as spouseMinReg
    // ─── ADDRESS ───────────────────────────────────────────
    r(850, 1002, v('gov'));
    r(616, 1002, v('district'));
    r(386, 1002, v('area'));
    r(114, 1002, v('neighborhood'));

    r(784, 1030, v('street'));
    r(470, 1030, v('area'));        // المنطقة العقارية (maybe reuse area)
    r(104, 1035, v('property'));

    r(828, 1042, v('building'));
    r(504, 1050, v('floor'));
    l(300, 1050, v('phone'));
    l(50, 1070, v('fax'));

    l(656, 1086, v('email'));
    // After the fax line or wherever they appear on the form
r(638, 1068, v('poBoxArea'));     // منطقة صندوق البريد
l(796, 1062, v('poBoxNumber'));   // رقم صندوق البريد
    // ─── DECLARATION ───────────────────────────────────────
    r(700, 1162, '${v('firstName')} ${v('lastName')}'); // إسم المستخدم/الأجير
    l(216, 1184, today[0]); // day
    l(142, 1184, today[1]); // month
    l(68, 1184, today[2]);  // year

    // ─── BUILD PDF ─────────────────────────────────────────
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(children: [
            pw.Positioned.fill(child: pw.Image(templateImage, fit: pw.BoxFit.fill)),
            ...o,
          ]),
        );
      },
    ));

    return Uint8List.fromList(await pdf.save());
  }

  // ══════════════════════════════════════════════════════════
  // DIALOG UI
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    const rtl = ui.TextDirection.rtl;
    const ltr = ui.TextDirection.ltr;

    Widget tf(String key, String label,
        {bool isLtr = false, TextInputType? kb, String? hint}) {
      return TextField(
        controller: c[key],
        textDirection: isLtr ? ltr : rtl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        keyboardType: kb,
      );
    }

    Widget section(String title) {
      return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 12),
        child: Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: const Color(0xFF0D47A1),
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
      );
    }

    Widget row2(Widget a, Widget b) {
      return Row(
        children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ],
      );
    }

    return Directionality(
      textDirection: rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بيان معلومات من المستخدم/الأجير',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'R4 — ${widget.employee.fullName}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      section('تعريف'),
                      row2(tf('firstName', 'الاسم'), tf('lastName', 'الشهرة')),
                      const SizedBox(height: 12),
                      row2(tf('fatherName', 'اسم الأب'), tf('motherName', 'اسم الأم وشهرتها قبل الزواج')),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: genderVal,
                              decoration: const InputDecoration(labelText: 'الجنس'),
                              items: const [
                                DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                                DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                              ],
                              onChanged: (v) => setState(() => genderVal = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: tf('nationality', 'الجنسية')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      row2(tf('placeOfBirth', 'محل الولادة'), tf('dob', 'تاريخ الولادة', isLtr: true, hint: 'YYYY-MM-DD')),
                      const SizedBox(height: 12),
                      row2(tf('registerNum', 'رقم السجل', isLtr: true), tf('registerPlace', 'مكان السجل')),
                      const SizedBox(height: 12),
                      row2(tf('idCard', 'رقم بطاقة الهوية', isLtr: true), Container()),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: maritalVal,
                              decoration: const InputDecoration(labelText: 'الوضع العائلي'),
                              items: const [
                                DropdownMenuItem(value: 'أعزب', child: Text('أعزب')),
                                DropdownMenuItem(value: 'متزوج', child: Text('متزوج')),
                                DropdownMenuItem(value: 'أرمل', child: Text('أرمل')),
                                DropdownMenuItem(value: 'مطلق', child: Text('مطلق')),
                              ],
                              onChanged: (v) => setState(() => maritalVal = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Container()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: wageTypeVal,
                              decoration: const InputDecoration(labelText: 'نوع الأجر'),
                              items: const [
                                DropdownMenuItem(value: 'full time', child: Text('شهري')),
                                DropdownMenuItem(value: 'daily', child: Text('يومي')),
                                DropdownMenuItem(value: 'hourly', child: Text('بالساعة')),
                              ],
                              onChanged: (v) => setState(() => wageTypeVal = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: tf('children', 'عدد الأولاد', isLtr: true, kb: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('رقم مالي شخصي؟', style: TextStyle(fontSize: 14)),
                              value: hasFinNum,
                              onChanged: (v) => setState(() => hasFinNum = v),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: tf('finNum', 'الرقم المالي', isLtr: true)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      row2(tf('ministryReg', 'رقم التسجيل (وزارة المالية)', isLtr: true), tf('email', 'البريد الإلكتروني', isLtr: true)),
                      const SizedBox(height: 12),
                      row2(tf('phone', 'رقم الهاتف', isLtr: true), Container()),

                      section('معلومات خاصة بالزوج/الزوجة'),
                      row2(tf('spouseName', 'اسم الزوج/الزوجة'), tf('spouseMaiden', 'الشهرة قبل الزواج')),
                      const SizedBox(height: 12),
                      row2(tf('spouseFather', 'اسم الأب'), tf('spouseMother', 'اسم الأم وشهرتها')),
                      const SizedBox(height: 12),
                      row2(tf('spouseNat', 'الجنسية'), tf('spousePob', 'محل الولادة')),
                      const SizedBox(height: 12),
                      row2(tf('spouseDob', 'تاريخ الولادة', isLtr: true, hint: 'YYYY-MM-DD'), tf('spouseId', 'رقم بطاقة الهوية', isLtr: true)),
                      const SizedBox(height: 12),
                      row2(tf('spouseRegNum', 'رقم السجل', isLtr: true), tf('spouseRegPlace', 'مكان السجل')),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('هل يعمل؟', style: TextStyle(fontSize: 14)),
                              value: spouseWorks,
                              onChanged: (v) => setState(() => spouseWorks = v),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: tf('spouseWorkDetails', 'تفاصيل العمل (اختياري)')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // NEW: Sector and Company fields
                      row2(
  tf('spouseWorkCompany', 'أ. اسم الشركة'),
  tf('spouseWorkSector', 'ب. اسم الإدارة'),
),
                      const SizedBox(height: 12),
                      row2(tf('spouseMinReg', 'رقم التسجيل (وزارة المالية)', isLtr: true), Container()),
                      const SizedBox(height: 12),
                      row2(tf('spouseRegNum2', 'رقم التسجيل (وزارة المالية) الثاني', isLtr: true), Container()),
                      section('عنوان السكن'),
                      row2(tf('gov', 'المحافظة'), tf('district', 'القضاء')),
                      const SizedBox(height: 12),
                      row2(tf('area', 'المنطقة'), tf('neighborhood', 'الحي')),
                      const SizedBox(height: 12),
                      row2(tf('street', 'الشارع'), tf('building', 'البناء')),
                      const SizedBox(height: 12),
                      row2(tf('floor', 'الطابق'), tf('property', 'رقم العقار', isLtr: true)),
                      const SizedBox(height: 12),
                      row2(
  tf('poBoxNumber', 'رقم صندوق البريد', isLtr: true),
  tf('poBoxArea', 'منطقة صندوق البريد'),
),
                      row2(tf('fax', 'فاكس', isLtr: true), Container()),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: _saving || _generatingPdf ? null : _saveOnly,
                      icon: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(_saving ? '...' : 'حفظ فقط'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _saving || _generatingPdf ? null : _saveAndGeneratePdf,
                      icon: _generatingPdf
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: Text(_generatingPdf ? 'جاري...' : 'حفظ + إنشاء PDF'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}