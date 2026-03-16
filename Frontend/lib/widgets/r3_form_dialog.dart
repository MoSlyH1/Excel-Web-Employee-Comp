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

class R3FormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const R3FormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<R3FormDialog> createState() => _R3FormDialogState();
}

class _R3FormDialogState extends State<R3FormDialog> {
  late final Map<String, TextEditingController> c;

  bool _loading = true;
  bool _saving = false;
  bool _generatingPdf = false;

  String? genderVal;
  String? maritalVal;
  String? wageTypeVal;
  bool hasFinNum = false;
bool spouseWorks = false;
  String _fmtDt(DateTime? d) =>
      d != null ? DateFormat('yyyy-MM-dd').format(d) : '';

  @override
  void initState() {
    super.initState();

    final e = widget.employee;
    genderVal = e.gender;
maritalVal = e.maritalStatus;
wageTypeVal = e.wageType;
hasFinNum = e.hasFinancialNumber ?? false;
spouseWorks = e.spouseWorks ?? false;
    c = {
  // company
  'companyName': TextEditingController(),
  'tradeName': TextEditingController(),
  'companyMinistryReg': TextEditingController(),
  'companySocialSecurity': TextEditingController(),

  // employee
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
  'socialSecurityNumber': TextEditingController(text: e.socialSecurityNumber ?? ''),
  'employeeMinistryReg': TextEditingController(text: e.ministryRegistrationNumber ?? ''),
  'phone': TextEditingController(text: e.phone ?? ''),
  'phone2': TextEditingController(text: e.phone2 ?? ''),
  'email': TextEditingController(text: e.email ?? ''),
  'workStartDate': TextEditingController(text: _fmtDt(e.workStartDate)),
  'joiningDate': TextEditingController(text: _fmtDt(e.joiningDate ?? e.startDate)),
  'basicSalary': TextEditingController(
    text: e.basicSalary != null ? e.basicSalary!.toStringAsFixed(0) : '',
  ),
  'otherAllowances': TextEditingController(
    text: e.otherAllowances != null ? e.otherAllowances!.toStringAsFixed(0) : '',
  ),
  'department': TextEditingController(text: e.department ?? ''),
  'jobPosition': TextEditingController(text: e.jobPosition ?? ''),
  'contractType': TextEditingController(text: e.contractType ?? ''),
  'bankAccount': TextEditingController(text: e.bankAccountNb ?? ''),

  // spouse
  'spouseName': TextEditingController(text: e.spouseName ?? ''),
  'spouseMaiden': TextEditingController(text: e.spouseMaidenName ?? ''),
  'spouseFather': TextEditingController(text: e.spouseFatherName ?? ''),
  'spouseMother': TextEditingController(text: e.spouseMotherName ?? ''),
  'spouseNat': TextEditingController(text: e.spouseNationality ?? ''),
  'spousePob': TextEditingController(text: e.spousePlaceOfBirth ?? ''),
  'spouseDob': TextEditingController(text: _fmtDt(e.spouseDateOfBirth)),
  'spouseId': TextEditingController(text: e.spouseIdCardNumber ?? ''),
  'spouseRegNum': TextEditingController(text: e.spouseRegisterNumber ?? ''),
  'spouseMinReg': TextEditingController(text: e.spouseRegistrationNumber ?? ''),
  'spouseRegNum2': TextEditingController(text: e.spouseRegistrationNumber2 ?? ''),
  'spouseWorkCompany': TextEditingController(text: e.spouseWorkCompany ?? ''),
  'spouseWorkSector': TextEditingController(text: e.spouseWorkSector ?? ''),
  'spouseWorkDetails': TextEditingController(text: e.spouseWorkDetails ?? ''),

  // address
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

  // R3-only / إفادة / خاص بالإدارة
  'socialSecurityStartDate': TextEditingController(
    text: _fmtDt(e.r3SocialSecurityStartDate),
  ),
  'employerName': TextEditingController(text: e.employerName ?? ''),
  'employerTitle': TextEditingController(text: e.employerTitle ?? ''),
  'r3FinancialNumber': TextEditingController(text: e.r3FinancialNumber ?? ''),
  'r3RegistrationDate': TextEditingController(
    text: _fmtDt(e.r3RegistrationDate),
  ),
  'r3RejectionReason': TextEditingController(text: e.r3RejectionReason ?? ''),
};

    genderVal = e.gender;
    maritalVal = e.maritalStatus;
    wageTypeVal = e.wageType;
    hasFinNum = e.hasFinancialNumber ?? false;

    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final data = await ApiService.getCompanyInfo();

      c['companyName']!.text = data['company_name'] ?? '';
      c['tradeName']!.text = data['trade_name'] ?? '';
      c['companyMinistryReg']!.text = data['ministry_reg_number'] ?? '';
      c['companySocialSecurity']!.text = data['social_security_number'] ?? '';
    } catch (_) {
      // keep defaults
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final ctrl in c.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  String? _ne(String? v) {
    if (v == null) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  int? _ni(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim());
  }

  double? _nd(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return double.tryParse(v.trim());
  }

  Map<String, dynamic> _buildEmployeePayload() {
  return {
    'first_name': _ne(c['firstName']!.text),
    'last_name': _ne(c['lastName']!.text),
    'father_name': _ne(c['fatherName']!.text),
    'mother_name': _ne(c['motherName']!.text),
    'gender': genderVal,
    'marital_status': maritalVal,
    'wage_type': wageTypeVal,
    'nationality': _ne(c['nationality']!.text),
    'place_of_birth': _ne(c['placeOfBirth']!.text),
    'date_of_birth': _ne(c['dob']!.text),
    'register_number': _ne(c['registerNum']!.text),
    'register_place': _ne(c['registerPlace']!.text),
    'id_card_number': _ne(c['idCard']!.text),
    'number_of_children': _ni(c['children']!.text),
    'has_financial_number': hasFinNum,
    'personal_financial_number': _ne(c['finNum']!.text),
    'ministry_registration_number': _ne(c['employeeMinistryReg']!.text),
    'phone': _ne(c['phone']!.text),
    'phone2': _ne(c['phone2']!.text),
    'email': _ne(c['email']!.text),
    'work_start_date': _ne(c['workStartDate']!.text),
    'joining_date': _ne(c['joiningDate']!.text),
    'basic_salary': _nd(c['basicSalary']!.text),
    'other_allowances': _nd(c['otherAllowances']!.text),
    'department': _ne(c['department']!.text),
    'job_position': _ne(c['jobPosition']!.text),
    'contract_type': _ne(c['contractType']!.text),
    'bank_account_nb': _ne(c['bankAccount']!.text),

    'governorate': _ne(c['gov']!.text),
    'district': _ne(c['district']!.text),
    'area': _ne(c['area']!.text),
    'neighborhood': _ne(c['neighborhood']!.text),
    'street': _ne(c['street']!.text),
    'building': _ne(c['building']!.text),
    'floor': _ne(c['floor']!.text),
    'property_number': _ne(c['property']!.text),
    'po_box_number': _ne(c['poBoxNumber']!.text),
    'po_box_area': _ne(c['poBoxArea']!.text),
    'fax': _ne(c['fax']!.text),

    'r3_social_security_start_date': _ne(c['socialSecurityStartDate']!.text),
    'employer_name': _ne(c['employerName']!.text),
    'employer_title': _ne(c['employerTitle']!.text),
    'r3_financial_number': _ne(c['r3FinancialNumber']!.text),
    'r3_registration_date': _ne(c['r3RegistrationDate']!.text),
    'r3_rejection_reason': _ne(c['r3RejectionReason']!.text),
  };
}

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    try {
      // save to employee record
      await ApiService.saveR3Data(widget.employee.id!, _buildEmployeePayload());

      widget.onDataChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('R3 data saved!'),
            backgroundColor: Color(0xFF2E7D32),
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
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _saveAndGeneratePdf() async {
    setState(() => _generatingPdf = true);
    try {
      // 1) save employee R3 data
      await ApiService.saveR3Data(widget.employee.id!, _buildEmployeePayload());

      // 2) generate pdf
      final pdfBytes = await _generateR3Pdf();

      // 3) upload to company docs
      final fileName =
          'R3_${widget.employee.employeeId}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      await ApiService.uploadCompanyDocument(
        fileName: fileName,
        fileBytes: pdfBytes,
        mimeType: 'application/pdf',
      );

      // 4) optional: also upload to employee docs
      await ApiService.uploadDocuments(
        employeeId: widget.employee.id!,
        fileNames: [fileName],
        fileBytes: [pdfBytes],
        mimeTypes: ['application/pdf'],
      );

      widget.onDataChanged();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF "$fileName" saved to company and employee documents!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  Future<Uint8List> _generateR3Pdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);
    
    final templateData = await rootBundle.load('assets/r3_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    String v(String key) => c[key]?.text.trim() ?? '';

    List<String> pd(String date) {
      if (date.isEmpty) return ['', '', ''];
      final p = date.split('-');
      return p.length == 3 ? [p[2], p[1], p[0]] : ['', '', ''];
    }

    final dob = pd(v('dob'));
    final joining = pd(v('joiningDate'));
    final ssDate = pd(v('socialSecurityStartDate'));
    final workStart = pd(v('workStartDate'));
    final r3RegDate = pd(v('r3RegistrationDate'));
    const sx = 595.28 / 1024.0;
    const sy = 841.89 / 1280.0;

    final ts = pw.TextStyle(
      font: arabicFont,
      fontSize: 9,
      color: PdfColors.blue900,
    );

    final tsChk = pw.TextStyle(
      font: arabicFont,
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue900,
    );

    final List<pw.Widget> o = [];

    void r(double px, double py, String text) {
      if (text.isEmpty) return;
      o.add(
        pw.Positioned(
          left: px * sx,
          top: py * sy,
          child: pw.Text(text, style: ts, textDirection: pw.TextDirection.rtl),
        ),
      );
    }

    void l(double px, double py, String text) {
      if (text.isEmpty) return;
      o.add(
        pw.Positioned(
          left: px * sx,
          top: py * sy,
          child: pw.Text(text, style: ts, textDirection: pw.TextDirection.ltr),
        ),
      );
    }

    void ck(double px, double py, bool val) {
      if (!val) return;
      o.add(
        pw.Positioned(
          left: px * sx,
          top: py * sy,
          child: pw.Text('X', style: tsChk),
        ),
      );
    }

    // ===== COMPANY =====
    r(604, 120, v('companyName'));
    r(224, 122, v('tradeName'));
    l(572, 166, v('companyMinistryReg'));

    // ===== EMPLOYEE =====


    r(744, 250, v('firstName'));
    r(302, 250, v('lastName'));
    r(728, 274, v('fatherName'));

    r(134, 282, v('motherName'));
    r(316, 312, v('nationality'));
    r(670, 342, v('placeOfBirth'));

    l(360, 338, dob[0]);
    l(284, 338, dob[1]);
    l(194, 338, dob[2]);

    r(390, 372, v('registerPlace'));
    l(806, 374, v('registerNum'));
    l(142, 374, v('idCard'));

    ck(852, 302, genderVal == 'ذكر');
    ck(766, 302, genderVal == 'أنثى');

    ck(800, 406, maritalVal == 'أعزب');
    ck(718, 406, maritalVal == 'متزوج');
    ck(634, 406, maritalVal == 'أرمل');
    ck(560, 406, maritalVal == 'مطلق');
    
    ck(490, 206, hasFinNum);      // نعم
ck(412, 206, !hasFinNum);     // كلا
l(24, 206, v('finNum'));      // اذكر الرقم

l(216, 404, v('children'));   // عدد الأولاد
l(80, 430, v('socialSecurityNumber')); // رقم الضمان الاجتماعي

ck(236, 464, wageTypeVal == 'full time'); // شهري
ck(158, 464, wageTypeVal == 'daily');     // يومي
ck(78, 464, wageTypeVal == 'hourly');    // بالساعة

l(750, 444, workStart[0]); // day
l(688, 444, workStart[1]); // month
l(626, 444, workStart[2]); // yearsss
// ─── SPOUSE ────────────────────────────────────────────
// ─── SPOUSE ────────────────────────────────────────────
r(720, 522, v('spouseName'));
r(302, 528, v('spouseMaiden'));

r(764, 558, v('spouseFather'));
r(196, 558, v('spouseMother'));

r(774, 598, v('spouseNat'));
r(266, 596, v('spousePob'));

final spDob = pd(v('spouseDob'));
l(800, 632, spDob[0]);
l(728, 632, spDob[1]);
l(654, 632, spDob[2]);
l(242, 632, v('spouseId'));

r(556, 672, v('spouseRegNum'));

ck(696, 708, spouseWorks);      // نعم
ck(616, 708, !spouseWorks);     // لا

l(624, 740, v('spouseMinReg'));   // رقم التسجيل الشخصي
l(28, 792, v('spouseRegNum2'));   // رقم السجل الشخصي

l(474, 798, v('spouseWorkCompany')); // اسم الشركة/المؤسسة
l(552, 836, v('spouseWorkSector'));  // اسم الإدارةs

    // ===== ADDRESS =====
    // ─── ADDRESS ───────────────────────────────────────────
r(862, 888, v('gov'));
r(664, 888, v('district'));
r(398, 888, v('area'));
r(152, 888, v('neighborhood'));

r(812, 906, v('street'));
r(460, 906, v('area'));        // المنطقة العقارية / reuse area unless you add separate field
r(94, 906, v('property'));

r(824, 918, v('building'));
r(530, 918, v('floor'));
l(324, 928, v('phone'));
l(90, 930, v('phone2'));
l(108, 954, v('fax'));

r(562, 944, v('poBoxArea'));
l(770, 944, v('poBoxNumber'));

l(600, 962, v('email'));

    // ===== EXTRA =====
 r(742, 1070, v('employerName'));          // اسم صاحب العمل
r(832, 1104, v('employerTitle'));         // الصفة

l(118, 1058, v('r3FinancialNumber'));     // الرقم المالي

l(260, 1100, r3RegDate[0]);               // day
l(194, 1100, r3RegDate[1]);               // month
l(126, 1100, r3RegDate[2]);               // year

r(200, 1152, v('r3RejectionReason'));     // سبب رفض التسجيل

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(templateImage, fit: pw.BoxFit.fill),
                ),
                ...o,
              ],
            ),
          );
        },
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    const rtl = ui.TextDirection.rtl;
    const ltr = ui.TextDirection.ltr;

    Widget tf(
      String key,
      String label, {
      bool isLtr = false,
      TextInputType? kb,
      String? hint,
    }) {
      return TextField(
        controller: c[key],
        textDirection: isLtr ? ltr : rtl,
        keyboardType: kb,
        decoration: InputDecoration(labelText: label, hintText: hint),
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
                  color: const Color(0xFF6A1B9A),
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

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Directionality(
      textDirection: rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 850),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب تسجيل مستخدم/أجير جديد (R3)',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'R3 — ${widget.employee.fullName}',
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
                      section('معلومات الشركة'),
                      row2(tf('companyName', 'إسم الشركة/المؤسسة'), tf('tradeName', 'الشهرة التجارية')),
                      const SizedBox(height: 12),
                      row2(
                        tf('companyMinistryReg', 'رقم التسجيل (وزارة المالية)', isLtr: true),
                        tf('companySocialSecurity', 'رقم الضمان الاجتماعي', isLtr: true),
                      ),

                      section('تعريف الأجير'),
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
                      row2(
                        tf('placeOfBirth', 'محل الولادة'),
                        tf('dob', 'تاريخ الولادة', isLtr: true, hint: 'YYYY-MM-DD'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('registerNum', 'رقم السجل', isLtr: true),
                        tf('registerPlace', 'مكان السجل'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('idCard', 'رقم بطاقة الهوية', isLtr: true),
                        tf('employeeMinistryReg', 'رقم التسجيل (وزارة المالية)', isLtr: true),
                      ),
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
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('رقم مالي شخصي؟', style: TextStyle(fontSize: 14)),
                              value: hasFinNum,
                              onChanged: (v) => setState(() => hasFinNum = v),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('finNum', 'الرقم المالي الشخصي', isLtr: true),
                        tf('children', 'عدد الأولاد', isLtr: true, kb: TextInputType.number),
                      ),
                      const SizedBox(height: 12),
row2(
  tf('socialSecurityNumber', 'رقم الضمان الاجتماعي', isLtr: true),
  tf('employeeMinistryReg', 'رقم التسجيل (وزارة المالية)', isLtr: true),
),
                      section('العمل والأجر'),
                      row2(tf('jobPosition', 'الوظيفة'), tf('department', 'القسم')),
                      const SizedBox(height: 12),

                      row2(
  tf('contractType', 'نوع العقد'),
  tf('joiningDate', 'تاريخ المباشرة', isLtr: true, hint: 'YYYY-MM-DD'),
),
const SizedBox(height: 12),
tf('workStartDate', 'تاريخ ابتدأ العمل', isLtr: true, hint: 'YYYY-MM-DD'),

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
                          Expanded(
                            child: tf(
                              'socialSecurityStartDate',
                              'تاريخ التسجيل بالضمان',
                              isLtr: true,
                              hint: 'YYYY-MM-DD',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('basicSalary', 'الراتب الأساسي', isLtr: true, kb: TextInputType.number),
                        tf('otherAllowances', 'بدلات أخرى', isLtr: true, kb: TextInputType.number),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('bankAccount', 'رقم الحساب المصرفي', isLtr: true),
                        Container(),
                      ),





                        section('معلومات خاصة بالزوج/الزوجة'),
row2(
  tf('spouseName', 'اسم الزوج/الزوجة'),
  tf('spouseMaiden', 'الشهرة قبل الزواج'),
),
const SizedBox(height: 12),
row2(
  tf('spouseFather', 'اسم الأب'),
  tf('spouseMother', 'اسم الأم وشهرتها قبل الزواج'),
),
const SizedBox(height: 12),
row2(
  tf('spouseNat', 'الجنسية'),
  tf('spousePob', 'محل الولادة'),
),
const SizedBox(height: 12),
row2(
  tf('spouseDob', 'تاريخ الولادة', isLtr: true, hint: 'YYYY-MM-DD'),
  tf('spouseId', 'رقم بطاقة الهوية', isLtr: true),
),
const SizedBox(height: 12),
tf(
  'spouseRegNum',
  'عدد من الاشخاص الذين يستفيدون',
  isLtr: true,
  kb: TextInputType.number,
),
const SizedBox(height: 12),
SwitchListTile(
  title: const Text(
    'هل الزوج/الزوجة يعمل؟',
    style: TextStyle(fontSize: 13),
    overflow: TextOverflow.ellipsis,
  ),
  value: spouseWorks,
  onChanged: (v) => setState(() => spouseWorks = v),
  dense: true,
  contentPadding: EdgeInsets.zero,
),
const SizedBox(height: 12),
row2(
  tf('spouseMinReg', 'رقم التسجيل الشخصي', isLtr: true),
  tf('spouseRegNum2', 'رقم السجل الشخصي', isLtr: true),
),
const SizedBox(height: 12),
row2(
  tf('spouseWorkCompany', 'اسم الشركة / المؤسسة'),
  tf('spouseWorkSector', 'اسم الإدارة'),
),
const SizedBox(height: 12),
tf('spouseWorkDetails', 'تفاصيل إضافية'),



const SizedBox(height: 12),
tf('spouseWorkDetails', 'تفاصيل إضافية'),
                      section('عنوان السكن'),
                      row2(tf('gov', 'المحافظة'), tf('district', 'القضاء')),
                      const SizedBox(height: 12),
                      row2(tf('area', 'المنطقة'), tf('neighborhood', 'الحي')),
                      const SizedBox(height: 12),
                      row2(tf('street', 'الشارع'), tf('building', 'البناء')),
                      const SizedBox(height: 12),
                      row2(
                        tf('floor', 'الطابق'),
                        tf('property', 'رقم العقار', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('poBoxNumber', 'رقم صندوق البريد', isLtr: true),
                        tf('poBoxArea', 'منطقة صندوق البريد'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('phone', 'رقم الهاتف', isLtr: true),
                        tf('phone2', '2 رقم الهاتف', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      tf('fax', 'فاكس', isLtr: true),
                      const SizedBox(height: 12),
                      tf('email', 'البريد الإلكتروني', isLtr: true),

                      section('الإفادة'),
row2(
  tf('employerName', 'اسم صاحب العمل'),
  tf('employerTitle', 'صفة', isLtr: false),
),
const SizedBox(height: 12),
row2(
  tf('r3FinancialNumber', 'الرقم المالي', isLtr: true),
  tf('r3RegistrationDate', 'تاريخ التسجيل', isLtr: true, hint: 'YYYY-MM-DD'),
),
const SizedBox(height: 12),
tf('r3RejectionReason', 'سبب رفض التسجيل'),
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
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(_saving ? '...' : 'حفظ فقط'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _saving || _generatingPdf ? null : _saveAndGeneratePdf,
                      icon: _generatingPdf
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: Text(_generatingPdf ? 'جاري...' : 'حفظ + إنشاء PDF'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
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