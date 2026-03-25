import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:employee_hub/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/employee.dart';

class E3lamFormDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const E3lamFormDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<E3lamFormDialog> createState() => _E3lamFormDialogState();
}

class _E3lamFormDialogState extends State<E3lamFormDialog> {
  late final Map<String, TextEditingController> c;

  String genderVal = 'ذكر';
  String maritalStatusVal = 'أعزب';
  String leaveReasonVal = 'استقالة';

  bool _generatingPdf = false;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    c = {
      'institutionResponsible': TextEditingController(
  text: e.institutionResponsible ?? '',
),
'institutionNssfNumber': TextEditingController(
  text: e.institutionNssfNumber ?? '',
),
'institutionPlace': TextEditingController(
  text: e.institutionPlace ?? '',
),
'institutionNumber': TextEditingController(
  text: e.institutionNumber ?? '',
),
'institutionPhone': TextEditingController(
  text: e.institutionPhone ?? e.phone ?? '',
),
'institutionFullAddress': TextEditingController(
  text: e.institutionFullAddress ?? '',
),

'employeeFundNumber': TextEditingController(
  text: e.employeeFundNumber ?? '',
),
'employeeName': TextEditingController(
  text: e.employeeName ?? e.firstName ?? '',
),
'employeeSurname': TextEditingController(
  text: e.employeeSurname ?? e.lastName ?? '',
),
'fatherName': TextEditingController(
  text: e.fatherNameE3lam ?? e.fatherName ?? '',
),
'motherName': TextEditingController(
  text: e.motherNameE3lam ?? e.motherName ?? '',
),
'birthDatePlace': TextEditingController(
  text: e.birthDatePlace ?? _joinParts([
    _fmtDate(e.dateOfBirth),
    e.placeOfBirth,
  ]),
),
'registerNumber': TextEditingController(
  text: e.registerNumberE3lam ?? e.registerNumber ?? '',
),
'nationality': TextEditingController(
  text: e.nationality ?? '',
),

'leftWorkSince': TextEditingController(
  text: e.leftWorkSince ?? '',
),
'currentJob': TextEditingController(
  text: e.currentJob ?? e.jobPosition ?? '',
),
'salaryAtLeaveDate': TextEditingController(
  text: e.salaryAtLeaveDate ??
      (e.basicSalary != null ? e.basicSalary!.toStringAsFixed(0) : ''),
),
'beirutDate': TextEditingController(
  text: e.beirutDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
),

'employeeSignedName': TextEditingController(
  text: e.employeeSignedName ?? e.fullName,
),
'date': TextEditingController(
  text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
),
'centerNumber': TextEditingController(
  text: e.centerNumber ?? '',
),
'registrationDepartmentName': TextEditingController(
  text: e.registrationDepartmentName ?? '',
),
'registrationDepartmentDate': TextEditingController(
  text: e.registrationDepartmentDate ?? '',
),
'registrationProcessedDate': TextEditingController(
  text: e.registrationProcessedDate ?? '',
),
    };

    if ((e.gender ?? '').trim().isNotEmpty) {
  genderVal = e.gender!.trim();
}
if ((e.maritalStatus ?? '').trim().isNotEmpty) {
  maritalStatusVal = e.maritalStatus!.trim();
}
    if ((e.leaveReason ?? '').trim().isNotEmpty) {
  leaveReasonVal = e.leaveReason!.trim();
}
  }
  Map<String, dynamic> _buildDataMap() {
  String? ne(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();

  return {
    'institution_responsible': ne(c['institutionResponsible']?.text),
    'institution_nssf_number': ne(c['institutionNssfNumber']?.text),
    'institution_place': ne(c['institutionPlace']?.text),
    'institution_number': ne(c['institutionNumber']?.text),
    'institution_phone': ne(c['institutionPhone']?.text),
    'institution_full_address': ne(c['institutionFullAddress']?.text),

    'employee_fund_number': ne(c['employeeFundNumber']?.text),
    'employee_name': ne(c['employeeName']?.text),
    'employee_surname': ne(c['employeeSurname']?.text),
    'father_name': ne(c['fatherName']?.text),
    'mother_name': ne(c['motherName']?.text),
    'birth_date_place': ne(c['birthDatePlace']?.text),
    'register_number': ne(c['registerNumber']?.text),
    'nationality': ne(c['nationality']?.text),

    'gender': genderVal,
    'marital_status': maritalStatusVal,
    'left_work_since': ne(c['leftWorkSince']?.text),
    'leave_reason': leaveReasonVal,
    'current_job': ne(c['currentJob']?.text),
    'salary_at_leave_date': ne(c['salaryAtLeaveDate']?.text),
    'beirut_date': ne(c['beirutDate']?.text),

    'employee_signed_name': ne(c['employeeSignedName']?.text),
    'center_number': ne(c['centerNumber']?.text),
    'registration_department_name': ne(c['registrationDepartmentName']?.text),
    'registration_department_date': ne(c['registrationDepartmentDate']?.text),
    'registration_processed_date': ne(c['registrationProcessedDate']?.text),
  };
}
  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return DateFormat('yyyy-MM-dd').format(d);
  }

  static String _joinParts(List<String?> parts) {
    final values = parts
        .where((x) => x != null && x!.trim().isNotEmpty)
        .map((x) => x!.trim())
        .toList();
    return values.join(' - ');
  }

  @override
  void dispose() {
    for (final ctrl in c.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _tf(
    String key,
    String label, {
    bool isLtr = false,
    TextInputType? kb,
    int maxLines = 1,
  }) {
    return TextField(
      controller: c[key],
      textDirection: isLtr ? ui.TextDirection.ltr : ui.TextDirection.rtl,
      keyboardType: kb,
      maxLines: maxLines,
      decoration: _dec(label),
    );
  }

  Widget _row2(Widget a, Widget b) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
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
  Future<void> _saveOnly() async {
  if (widget.employee.id == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Employee database ID is missing'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _saving = true);

  try {
    await ApiService.saveE3lamData(
      widget.employee.id!,
      _buildDataMap(),
    );

    widget.onDataChanged();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ بيانات الإعلام'),
        backgroundColor: Color(0xFF00897B),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('فشل حفظ البيانات: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _saving = false);
    }
  }
}
  Future<void> _savePdfToEmployeeDocuments({
  required String fileName,
  required Uint8List bytes,
}) async {
  final int? employeeDbId = widget.employee.id;

  if (employeeDbId == null) {
    throw Exception('Employee database ID is missing');
  }

  await ApiService.uploadDocuments(
    employeeId: employeeDbId,
    fileNames: [fileName],
    fileBytes: [bytes],
    mimeTypes: ['application/pdf'],
  );
}

  Future<void> _generateAndSavePdf() async {
    setState(() => _generatingPdf = true);

    try {
      await ApiService.saveE3lamData(
  widget.employee.id!,
  _buildDataMap(),
);
      final pdfBytes = await _generateE3lamPdf();

      final fileName =
    'e3lam_${widget.employee.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await _savePdfToEmployeeDocuments(
        fileName: fileName,
        bytes: pdfBytes,
      );

      if (!mounted) return;

      widget.onDataChanged();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ ملف الإعلام في مستندات الأجير'),
          backgroundColor: Color(0xFF00897B),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _generatingPdf = false);
      }
    }
  }

  Future<Uint8List> _generateE3lamPdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData =
        await rootBundle.load('assets/e3lam_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    String v(String key) => c[key]?.text.trim() ?? '';

    List<String> splitDate(String date) {
      if (date.isEmpty) return ['', '', ''];
      final p = date.split('-');
      return p.length == 3 ? [p[2], p[1], p[0]] : ['', '', ''];
    }

    final beirutDate = splitDate(v('beirutDate'));
    final signDate = splitDate(v('date'));

    const sx = 1.0;
    const sy = 1.0;

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

    void r(double rightX, double y, String text, {required double width, pw.TextStyle? style}) {
  if (text.isEmpty) return;
  o.add(
    pw.Positioned(
      left: rightX - width,
      top: y,
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
    ),
  );
}

void l(double leftX, double y, String text, {required double width, pw.TextStyle? style}) {
  if (text.isEmpty) return;
  o.add(
    pw.Positioned(
      left: leftX,
      top: y,
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

    l(580, 288, v('institutionResponsible'), width: 260);
    l(98, 320, v('institutionNssfNumber'), width: 180);

    l(726, 346, v('institutionPlace'), width: 110);
    l(496, 346, v('institutionNumber'), width: 80);
    l(288, 346, v('institutionPhone'), width: 120);

    l(504, 396, v('institutionFullAddress'), width: 620);

    l(98, 438, v('employeeFundNumber'), width: 180);

    ck(840, 468, genderVal == 'ذكر');
    ck(736, 466, genderVal == 'أنثى');

    l(656, 486, v('employeeName'), width: 150);
    l(228, 486, v('employeeSurname'), width: 150);

    l(716, 514, v('fatherName'), width: 160);
    l(238, 510, v('motherName'), width: 240);

    l(614, 540, v('birthDatePlace'), width: 375);
    l(408, 540, v('registerNumber'), width: 170);
    l(158, 540, v('nationality'), width: 110);

    ck(780, 598, maritalStatusVal == 'أعزب');
    ck(680, 598, maritalStatusVal == 'متأهل');
    ck(592, 598, maritalStatusVal == 'أرمل');
    ck(496, 598, maritalStatusVal == 'مطلق');
    ck(402, 598, maritalStatusVal == 'هاجر');

    l(616, 622, v('leftWorkSince'), width: 220);

    ck(812, 650, leaveReasonVal == 'استقالة');
    ck(712, 650, leaveReasonVal == 'بلوغ السن');
    ck(602, 650, leaveReasonVal == 'عجز');
    ck(510, 650, leaveReasonVal == 'زواج');
    ck(416, 650, leaveReasonVal == 'وفاة');
    ck(340, 650, leaveReasonVal == 'هجرة');
    ck(246, 650, leaveReasonVal == 'عمل آخر');

    l(562, 676, v('currentJob'), width: 270);
    l(416, 700, v('salaryAtLeaveDate'), width: 160);

    l(828, 750, beirutDate[0], width: 35);
    l(794, 750, beirutDate[1], width: 35);
    l(746, 750, beirutDate[2], width: 55);

    l(230, 888, v('employeeSignedName'), width: 220);
    l(740, 920, signDate[0], width: 30);
    l(698, 920, signDate[1], width: 30);
    l(632, 920, signDate[2], width: 55);

    l(652, 1000, v('centerNumber'), width: 120);
    l(220, 972, v('registrationDepartmentName'), width: 200);
    l(246, 1000, v('registrationDepartmentDate'), width: 150);
    l(730, 1028, v('registrationProcessedDate'), width: 150);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(1024, 1280),
        margin: pw.EdgeInsets.zero,
        build: (ctx) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Positioned(
  left: 0,
  top: 0,
  child: pw.Image(
    templateImage,
    width: 1024,
    height: 1280,
  ),
),
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
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 860),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E244D), Color(0xFFB23A5B)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'إعلام عن ترك أجير عمله في المؤسسة',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _section('بيانات المؤسسة'),
                      _row2(
                        _tf('institutionResponsible', 'المسؤول عن المؤسسة'),
                        _tf(
                          'institutionNssfNumber',
                          'المسجلة في الصندوق الوطني للضمان الاجتماعي تحت رقم',
                          isLtr: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _row2(
                        _tf('institutionPlace', 'مكان'),
                        _tf('institutionNumber', 'رقم', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      _row2(
                        _tf('institutionPhone', 'هاتف', isLtr: true),
                        _tf(
                          'institutionFullAddress',
                          'العنوان الكامل',
                          maxLines: 2,
                        ),
                      ),
                      _section('بيانات الأجير'),
                      _row2(
                        _tf(
                          'employeeFundNumber',
                          'المسجل في صندوق تحت رقم',
                          isLtr: true,
                        ),
                        DropdownButtonFormField<String>(
                          value: genderVal,
                          decoration: _dec('الجنس'),
                          items: const [
                            DropdownMenuItem(
                              value: 'ذكر',
                              child: Text('ذكر'),
                            ),
                            DropdownMenuItem(
                              value: 'أنثى',
                              child: Text('أنثى'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => genderVal = v ?? 'ذكر'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _row2(
                        _tf('employeeName', 'اسم الأجير'),
                        _tf('employeeSurname', 'الشهرة'),
                      ),
                      const SizedBox(height: 12),
                      _row2(
                        _tf('fatherName', 'اسم الأب'),
                        _tf('motherName', 'اسم الأم وشهرتها'),
                      ),
                      const SizedBox(height: 12),
                      _row2(
                        _tf('birthDatePlace', 'تاريخ و محل ولادة الأجير'),
                        _tf('registerNumber', 'رقم السجل'),
                      ),
                      const SizedBox(height: 12),
                      _tf('nationality', 'الجنسية'),
                      _section('الوضع العائلي وترك العمل'),
                      _row2(
                        DropdownButtonFormField<String>(
                          value: maritalStatusVal,
                          decoration: _dec('الوضع العائلي'),
                          items: const [
                            DropdownMenuItem(
                              value: 'أعزب',
                              child: Text('أعزب'),
                            ),
                            DropdownMenuItem(
                              value: 'متأهل',
                              child: Text('متأهل'),
                            ),
                            DropdownMenuItem(
                              value: 'أرمل',
                              child: Text('أرمل'),
                            ),
                            DropdownMenuItem(
                              value: 'مطلق',
                              child: Text('مطلق'),
                            ),
                            DropdownMenuItem(
                              value: 'هاجر',
                              child: Text('هاجر'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => maritalStatusVal = v ?? 'أعزب'),
                        ),
                        _tf('leftWorkSince', 'ترك العمل بها منذ'),
                      ),
                      const SizedBox(height: 12),
                      _row2(
                        DropdownButtonFormField<String>(
                          value: leaveReasonVal,
                          decoration: _dec('سبب ترك العمل'),
                          items: const [
                            DropdownMenuItem(
                              value: 'استقالة',
                              child: Text('استقالة'),
                            ),
                            DropdownMenuItem(
                              value: 'بلوغ السن',
                              child: Text('بلوغ السن'),
                            ),
                            DropdownMenuItem(
                              value: 'عجز',
                              child: Text('عجز'),
                            ),
                            DropdownMenuItem(
                              value: 'زواج',
                              child: Text('زواج'),
                            ),
                            DropdownMenuItem(
                              value: 'وفاة',
                              child: Text('وفاة'),
                            ),
                            DropdownMenuItem(
                              value: 'هجرة',
                              child: Text('هجرة'),
                            ),
                            DropdownMenuItem(
                              value: 'عمل آخر',
                              child: Text('عمل آخر'),
                            ),
                          ],
                          onChanged: (v) => setState(
                            () => leaveReasonVal = v ?? 'استقالة',
                          ),
                        ),
                        _tf('currentJob', 'عمل الأجير الحالي'),
                      ),
                      const SizedBox(height: 12),
                      _row2(
                        _tf(
                          'salaryAtLeaveDate',
                          'إن راتب الأجير بتاريخ ترك العمل هو',
                          isLtr: true,
                          kb: TextInputType.number,
                        ),
                        _tf('beirutDate', 'بيروت في', isLtr: true),
                      ),
                      _section('التوقيع والمعالجة'),
                      _row2(
                        _tf('employeeSignedName', 'اسم الأجير'),
                        _tf('date', 'التاريخ', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      _row2(
  _tf('centerNumber', 'عولج في مركز رقم', isLtr: true),
  _tf('registrationDepartmentName', 'عولج في دائرة التسجيل', isLtr: true),
),

const SizedBox(height: 12),

_row2(
  _tf('registrationDepartmentDate', 'بتاريخ', isLtr: true),
  _tf('registrationProcessedDate', 'بتاريخ', isLtr: true),
),
                      const SizedBox(height: 12),
                      _tf(
                        'registrationProcessedDate',
                        'بتاريخ',
                        isLtr: true,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
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
      label: Text(_saving ? 'جاري الحفظ...' : 'حفظ فقط'),
    ),
    const SizedBox(width: 8),
    FilledButton.icon(
      onPressed: _saving || _generatingPdf ? null : _generateAndSavePdf,
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
      label: Text(_generatingPdf ? 'جاري الإنشاء...' : 'حفظ + إنشاء PDF'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF8E244D),
      ),
    ),
  ],
)
              ),
            ],
          ),
        ),
      ),
    );
  }
}