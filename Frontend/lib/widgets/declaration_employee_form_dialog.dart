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

class DeclarationEmployeeFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const DeclarationEmployeeFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<DeclarationEmployeeFormDialog> createState() =>
      _DeclarationEmployeeFormDialogState();
}

class _DeclarationEmployeeFormDialogState
    extends State<DeclarationEmployeeFormDialog> {
  late final Map<String, TextEditingController> c;

  String? genderVal;
  String? maritalVal;
  String? workTypeVal;
  String? paymentMethodVal;
  bool hasOtherEmployer = false;

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

    // ── Computed helpers ─────────────────────────────────────────
    final birthDatePlace = _pick([
      e.declBirthDatePlace,
      e.birthDatePlace,
      [_fmtDt(e.dateOfBirth), e.placeOfBirth]
          .where((s) => s != null && s!.isNotEmpty)
          .join(' - '),
    ]);

    final buildingFloor = _pick([
      e.declCurrentBuildingFloor,
      [e.building, e.floor]
          .where((s) => s != null && s!.isNotEmpty)
          .join(' ط'),
    ]);

    c = {
      // ── أ: المؤسسة — pre-filled by _loadCompanyInfo() ────────
      'employerName':
          TextEditingController(text: e.declEmployerName ?? ''), // Changed from hardcoded string to empty
      'commercialRegPlace':
          TextEditingController(text: e.declCommercialRegPlace ?? ''),
      'commercialRegNumber':
          TextEditingController(text: e.declCommercialRegNumber ?? ''),
      'employerPhone':
          TextEditingController(text: e.declEmployerPhone ?? ''),
      'workplaceAddress':
          TextEditingController(text: e.declWorkplaceAddress ?? ''),

      // ── ب: الأجير — auto-filled from R4 fields ───────────────
      'employeeFirstName': TextEditingController(
          text: _pick([e.declEmployeeFirstName, e.firstName])),
      'employeeLastName': TextEditingController(
          text: _pick([e.declEmployeeLastName, e.lastName])),
      'employeeFatherName': TextEditingController(
          text: _pick([e.declEmployeeFatherName, e.fatherName])),
      'employeeMotherName': TextEditingController(
          text: _pick([e.declEmployeeMotherName, e.motherName])),
      'birthDatePlace':
          TextEditingController(text: birthDatePlace),
      'birthDistrict': TextEditingController(
          text: _pick([e.declBirthDistrict, e.registerPlace])),
      'registerNumber': TextEditingController(
          text: _pick([e.declRegisterNumber, e.registerNumber])),
      'religion':
          TextEditingController(text: e.declReligion ?? ''),
      'idResidencePlace': TextEditingController(
          text: _pick([e.declIdResidencePlace, e.registerPlace])),

      // ── ٩: عنوان السكن — auto-filled from R4 address ─────────
      'currentGovernorate': TextEditingController(
          text: _pick([e.declCurrentGovernorate, e.governorate])),
      'currentDistrict': TextEditingController(
          text: _pick([e.declCurrentDistrict, e.district])),
      'currentCity': TextEditingController(
          text: _pick([e.declCurrentCity, e.area])),
      'currentNeighborhood': TextEditingController(
          text: _pick([e.declCurrentNeighborhood, e.neighborhood])),
      'currentStreet': TextEditingController(
          text: _pick([e.declCurrentStreet, e.street])),
      'currentBuildingFloor':
          TextEditingController(text: buildingFloor),
      'currentPhone': TextEditingController(
          text: _pick([e.declCurrentPhone, e.phone])),

      // ── ١٠–١٢: عمل — auto-filled from employment fields ──────
      'workStartDate': TextEditingController(
          text: _pick([e.declWorkStartDate, _fmtDt(e.startDate)])),
      'monthlyHours':
          TextEditingController(text: e.declMonthlyHours ?? ''),
      'currentJob': TextEditingController(
          text: _pick([e.declCurrentJob, e.jobPosition])),
      'currentSalary': TextEditingController(
          text: _pick([
            e.declCurrentSalary,
            e.basicSalary != null
                ? e.basicSalary!.toStringAsFixed(0)
                : null,
          ])),
      'salaryAtEntry':
          TextEditingController(text: e.declSalaryAtEntry ?? ''),

      // ── ١٣–١٥ ─────────────────────────────────────────────────
      'nationality': TextEditingController(
          text: _pick([e.declNationality, e.nationality])),
      'workPermit':
          TextEditingController(text: e.declWorkPermit ?? ''),
      'otherEmployerInfo':
          TextEditingController(text: e.declOtherEmployerInfo ?? ''),

      // ── توقيع ─────────────────────────────────────────────────
      'employeeSignedName': TextEditingController(
          text: _pick([e.declEmployeeSignedName, e.fullName])),
      'declarationDate': TextEditingController(
          text: e.declDeclarationDate != null
              ? _fmtDt(e.declDeclarationDate)
              : DateFormat('yyyy-MM-dd').format(DateTime.now())),
    };

    genderVal =
        _pick([e.declEmployeeGender, e.gender]).let((s) => s.isNotEmpty ? s : null) ?? 'ذكر';
    maritalVal =
        _pick([e.declMaritalStatus, e.maritalStatus]).let((s) => s.isNotEmpty ? s : null) ?? 'أعزب';
    workTypeVal = e.declWorkType ?? 'كامل';
    paymentMethodVal = e.declPaymentMethod ?? 'شهري';
    hasOtherEmployer = e.declHasOtherEmployer ?? false;

    // Auto-fill employer section from company info (same as e3lam)
    _loadCompanyInfo();
  }

  // ── Company info auto-fill (mirrors e3lam pattern exactly) ─────────
  Future<void> _loadCompanyInfo() async {
    try {
      final company = await ApiService.getCompanyInfo();
      if (!mounted) return;

      final companyName =
          (company['company_name'] ?? '').toString().trim();
      final tradeName =
          (company['trade_name'] ?? '').toString().trim();
      final displayName =
          tradeName.isNotEmpty ? tradeName : companyName;
      final companyMinReg =
          (company['ministry_reg_number'] ?? '').toString().trim();
      final companyPhone1 =
          (company['phone1'] ?? '').toString().trim();
      final companyPhone2 =
          (company['phone2'] ?? '').toString().trim();
      final companyGov =
          (company['governorate'] ?? '').toString().trim();
      final companyDistrict =
          (company['district'] ?? '').toString().trim();

      // Build full address from company address fields
      final companyAddressParts = <String>[
        if ((company['governorate'] ?? '').toString().trim().isNotEmpty)
          company['governorate'].toString().trim(),
        if ((company['district'] ?? '').toString().trim().isNotEmpty)
          company['district'].toString().trim(),
        if ((company['area'] ?? '').toString().trim().isNotEmpty)
          company['area'].toString().trim(),
        if ((company['neighborhood'] ?? '').toString().trim().isNotEmpty)
          company['neighborhood'].toString().trim(),
        if ((company['street'] ?? '').toString().trim().isNotEmpty)
          company['street'].toString().trim(),
        if ((company['cadastral_area'] ?? '').toString().trim().isNotEmpty)
          company['cadastral_area'].toString().trim(),
        if ((company['property_number'] ?? '').toString().trim().isNotEmpty)
          company['property_number'].toString().trim(),
        if ((company['building'] ?? '').toString().trim().isNotEmpty)
          company['building'].toString().trim(),
        if ((company['floor'] ?? '').toString().trim().isNotEmpty)
          'ط${company['floor'].toString().trim()}',
      ];
      final companyAddress = companyAddressParts.join(' - ');

      // ── Always override from company_info (same as R1-3 source of truth)
      if (displayName.isNotEmpty) c['employerName']?.text = displayName;
      if (companyMinReg.isNotEmpty) c['commercialRegNumber']?.text = companyMinReg;
      if (companyGov.isNotEmpty || companyDistrict.isNotEmpty) {
        c['commercialRegPlace']?.text =
            companyGov.isNotEmpty ? companyGov : companyDistrict;
      }
      final phone = companyPhone1.isNotEmpty ? companyPhone1 : companyPhone2;
      if (phone.isNotEmpty) c['employerPhone']?.text = phone;
      if (companyAddress.isNotEmpty) c['workplaceAddress']?.text = companyAddress;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to load company info for Declaration: $e');
    }
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
      'decl_employer_name':          ne(c['employerName']!.text),
      'decl_commercial_reg_place':   ne(c['commercialRegPlace']!.text),
      'decl_commercial_reg_number':  ne(c['commercialRegNumber']!.text),
      'decl_employer_phone':         ne(c['employerPhone']!.text),
      'decl_workplace_address':      ne(c['workplaceAddress']!.text),
      'decl_employee_gender':        genderVal,
      'decl_employee_first_name':    ne(c['employeeFirstName']!.text),
      'decl_employee_last_name':     ne(c['employeeLastName']!.text),
      'decl_employee_father_name':   ne(c['employeeFatherName']!.text),
      'decl_employee_mother_name':   ne(c['employeeMotherName']!.text),
      'decl_birth_date_place':       ne(c['birthDatePlace']!.text),
      'decl_birth_district':         ne(c['birthDistrict']!.text),
      'decl_register_number':        ne(c['registerNumber']!.text),
      'decl_marital_status':         maritalVal,
      'decl_religion':               ne(c['religion']!.text),
      'decl_id_residence_place':     ne(c['idResidencePlace']!.text),
      'decl_current_governorate':    ne(c['currentGovernorate']!.text),
      'decl_current_district':       ne(c['currentDistrict']!.text),
      'decl_current_city':           ne(c['currentCity']!.text),
      'decl_current_neighborhood':   ne(c['currentNeighborhood']!.text),
      'decl_current_street':         ne(c['currentStreet']!.text),
      'decl_current_building_floor': ne(c['currentBuildingFloor']!.text),
      'decl_current_phone':          ne(c['currentPhone']!.text),
      'decl_work_start_date':        ne(c['workStartDate']!.text),
      'decl_monthly_hours':          ne(c['monthlyHours']!.text),
      'decl_work_type':              workTypeVal,
      'decl_current_job':            ne(c['currentJob']!.text),
      'decl_current_salary':         ne(c['currentSalary']!.text),
      'decl_salary_at_entry':        ne(c['salaryAtEntry']!.text),
      'decl_payment_method':         paymentMethodVal,
      'decl_nationality':            ne(c['nationality']!.text),
      'decl_work_permit':            ne(c['workPermit']!.text),
      'decl_has_other_employer':     hasOtherEmployer,
      'decl_other_employer_info':    ne(c['otherEmployerInfo']!.text),
      'decl_employee_signed_name':   ne(c['employeeSignedName']!.text),
      'decl_declaration_date':       ne(c['declarationDate']!.text),
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
      final pdfBytes = await _generateDeclarationPdf();
      final fileName =
          'Declaration_${widget.employee.employeeId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
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
  // PDF GENERATION — PdfPageFormat(1024, 1280) raw pixel coordinates
  // ════════════════════════════════════════════════════════════════════
  Future<Uint8List> _generateDeclarationPdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData = await rootBundle
        .load('assets/employee_declaration_template_blank.png');
    final templateImage =
        pw.MemoryImage(templateData.buffer.asUint8List());

    String v(String key) => c[key]?.text.trim() ?? '';

    List<String> pd(String date) {
      if (date.isEmpty) return ['', '', ''];
      final p = date.split('-');
      return p.length == 3 ? [p[2], p[1], p[0]] : ['', '', ''];
    }

    final declDate = pd(v('declarationDate'));

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

    // ── أ: المؤسسة ────────────────────────────────────────────────
    l(448, 186, v('employerName'),        width: 470);
    l(722, 228, v('commercialRegPlace'),  width: 120);
    l(582, 228, v('commercialRegNumber'), width: 100);
    l(426, 228, v('employerPhone'),       width: 140);
    l(568, 278, v('workplaceAddress'),    width: 470);

    // ── ب: الجنس ─────────────────────────────────────────────────
    ck(820, 376, genderVal == 'ذكر');
    ck(720, 376, genderVal == 'أنثى');

    l(780, 400, v('employeeFirstName'),   width: 250);
    l(480, 400, v('employeeLastName'),    width: 150);
    l(782, 424, v('employeeFatherName'),  width: 300);
    l(488, 424, v('employeeMotherName'),  width: 150);
    l(722, 448, v('birthDatePlace'),      width: 220);
    l(552, 448, v('birthDistrict'),       width: 130);
    l(382, 448, v('registerNumber'),      width: 90);

    ck(760, 484, maritalVal == 'أعزب');
    ck(670, 484, maritalVal == 'متأهل');
    ck(598, 484, maritalVal == 'أرمل');
    ck(510, 484, maritalVal == 'مطلق');
    ck(404, 484, maritalVal == 'هاجر');

    l(422, 510, v('religion'),            width: 110);
    l(656, 508, v('idResidencePlace'),    width: 470);

    // ٩: عنوان السكن الحالي
    l(656, 540, v('currentGovernorate'),  width: 80);
    l(452, 540, v('currentDistrict'),     width: 100);
    l(756, 564, v('currentCity'),         width: 120);
    l(624, 564, v('currentNeighborhood'), width: 100);
    l(452, 564, v('currentStreet'),       width: 120);
    l(728, 594, v('currentBuildingFloor'),width: 200);
    l(454, 594, v('currentPhone'),        width: 130);

    // ١٠–١١: عمل
    l(700, 620, v('workStartDate'),       width: 160);
    l(378, 620, v('monthlyHours'),        width: 90);
    ck(786, 654, workTypeVal == 'كامل');
    ck(688, 654, workTypeVal == 'جزئي');
    l(740, 678, v('currentJob'),          width: 200);
    l(428, 678, v('currentSalary'),       width: 110);
    l(644, 706, v('salaryAtEntry'),       width: 200);

    // ١٢: طريقة الدفع
    ck(740, 736, paymentMethodVal == 'شهري');
    ck(652, 736, paymentMethodVal == 'أسبوعي');
    ck(580, 736, paymentMethodVal == 'يومي');
    ck(472, 736, paymentMethodVal == 'لقاء عمولة');
    ck(362, 736, paymentMethodVal == 'على الإنتاج');

    // ١٣–١٥
    l(520, 764, v('nationality'),         width: 200);
    l(436, 786, v('workPermit'),          width: 300);
    ck(504, 816, !hasOtherEmployer);  // نعم
    ck(418, 816,  hasOtherEmployer);  // كلا
    l(646, 848, v('otherEmployerInfo'),   width: 400);

    // توقيع / تاريخ
    l(500, 902, v('employeeSignedName'),  width: 200);
    l(308, 902, declDate[0],             width: 40);
    l(286, 902, declDate[1],             width: 40);
    l(242, 902, declDate[2],             width: 55);

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
                  child: pw.Image(templateImage,
                      width: 1024, height: 1280),
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
                  color: const Color(0xFF4A148C),
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

    Widget row3(Widget a, Widget b, Widget c2) => Row(children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
          const SizedBox(width: 8),
          Expanded(child: c2),
        ]);

    Widget dd(String label, String? val, List<String> opts,
        void Function(String?) onChanged) {
      return DropdownButtonFormField<String>(
        value: val,
        decoration: dec(label),
        items: opts
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      );
    }

    return Directionality(
      textDirection: rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 720, maxHeight: 860),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────
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
                  const Icon(Icons.badge_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تصريح باستخدام أجير',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'CNSS-2 AA — ${widget.employee.fullName}',
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
                      // ── أ: المؤسسة ─────────────────────────────
                      section('أ – معلومات خاصة بالمؤسسة'),
                      tf('employerName',
                          'اسم وشهرة صاحب العمل أو اسم الشركة'),
                      const SizedBox(height: 12),
                      row3(
                        tf('commercialRegPlace', 'مكان السجل التجاري'),
                        tf('commercialRegNumber', 'رقم السجل التجاري',
                            isLtr: true),
                        tf('employerPhone', 'هاتف', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      tf('workplaceAddress',
                          'عنوان المؤسسة (مكان عمل الأجير)'),

                      // ── ب: الأجير ──────────────────────────────
                      section('ب – معلومات خاصة بالأجير'),
                      dd('الجنس', genderVal, ['ذكر', 'أنثى'],
                          (v) => setState(() => genderVal = v)),
                      const SizedBox(height: 12),
                      row2(
                        tf('employeeFirstName', 'اسم الأجير'),
                        tf('employeeLastName', 'الشهرة'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('employeeFatherName', 'اسم الأب'),
                        tf('employeeMotherName', 'اسم الأم وشهرتها'),
                      ),
                      const SizedBox(height: 12),
                      row3(
                        tf('birthDatePlace', 'تاريخ ومحل الولادة',
                            isLtr: true),
                        tf('birthDistrict', 'القضاء'),
                        tf('registerNumber', 'رقم السجل', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        dd(
                          'الوضع العائلي',
                          maritalVal,
                          ['أعزب', 'متأهل', 'أرمل', 'مطلق', 'هاجر'],
                          (v) => setState(() => maritalVal = v),
                        ),
                        tf('religion', 'المذهب'),
                      ),
                      const SizedBox(height: 12),
                      tf('idResidencePlace', 'محل الإقامة (حسب الهوية)'),

                      // ── ٩: عنوان السكن ─────────────────────────
                      section('٩ – عنوان السكن الحالي'),
                      row3(
                        tf('currentGovernorate', 'المحافظة'),
                        tf('currentDistrict', 'القضاء'),
                        tf('currentCity', 'المدينة أو القرية'),
                      ),
                      const SizedBox(height: 12),
                      row3(
                        tf('currentNeighborhood', 'الحي'),
                        tf('currentStreet', 'الشارع'),
                        tf('currentBuildingFloor', 'بناية وطابق'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('currentPhone', 'هاتف', isLtr: true),
                        Container(),
                      ),

                      // ── ١٠–١٢: عمل ────────────────────────────
                      section('١٠–١٢ – العمل والأجر'),
                      row2(
                        tf('workStartDate', 'تاريخ دخول العمل',
                            isLtr: true, hint: 'YYYY-MM-DD'),
                        tf('monthlyHours', 'عدد ساعات عمله في الشهر',
                            isLtr: true, kb: TextInputType.number),
                      ),
                      const SizedBox(height: 12),
                      dd('دوام العمل', workTypeVal, ['كامل', 'جزئي'],
                          (v) => setState(() => workTypeVal = v)),
                      const SizedBox(height: 12),
                      row2(
                        tf('currentJob', 'عمل الأجير الحالي'),
                        tf('currentSalary', 'الراتب الحالي',
                            isLtr: true, kb: TextInputType.number),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('salaryAtEntry', 'الأجر بتاريخ دخول العمل',
                            isLtr: true, kb: TextInputType.number),
                        dd(
                          'طريقة دفع الأجر',
                          paymentMethodVal,
                          ['شهري', 'أسبوعي', 'يومي', 'لقاء عمولة', 'على الإنتاج'],
                          (v) => setState(() => paymentMethodVal = v),
                        ),
                      ),

                      // ── ١٣–١٥ ──────────────────────────────────
                      section('١٣–١٥ – معلومات إضافية'),
                      row2(
                        tf('nationality', 'الجنسية (إن كان أجنبياً)'),
                        tf('workPermit', 'رقم وتاريخ إجازة العمل',
                            isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'هل يعمل الأجير، حسب معرفتك، لدى صاحب عمل آخر؟',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(children: [
                              Checkbox(
                                value: !hasOtherEmployer,
                                onChanged: (v) => setState(
                                    () => hasOtherEmployer = !(v ?? true)),
                                activeColor: const Color(0xFF4A148C),
                              ),
                              const Text('نعم',
                                  style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 24),
                              Checkbox(
                                value: hasOtherEmployer,
                                onChanged: (v) => setState(
                                    () => hasOtherEmployer = v ?? false),
                                activeColor: const Color(0xFF4A148C),
                              ),
                              const Text('كلا',
                                  style: TextStyle(fontSize: 14)),
                            ]),
                            if (!hasOtherEmployer) ...[
                              const SizedBox(height: 8),
                              tf('otherEmployerInfo',
                                  'اسم ورقم صاحب العمل الآخر'),
                            ],
                          ],
                        ),
                      ),

                      // ── التوقيع ────────────────────────────────
                      section('التوقيع'),
                      row2(
                        tf('employeeSignedName', 'اسم الأجير'),
                        tf('declarationDate', 'التاريخ',
                            isLtr: true, hint: 'YYYY-MM-DD'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ────────────────────────────────────────
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

// Small extension to make the _pick().let() pattern work cleanly
extension _StringLet on String {
  T let<T>(T Function(String) block) => block(this);
}