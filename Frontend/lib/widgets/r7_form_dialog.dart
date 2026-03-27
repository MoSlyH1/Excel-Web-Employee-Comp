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

class R7FormDialog extends StatefulWidget {
  final Employee? employee; // Can be null for company-wide R7
  final VoidCallback onDataChanged;

  const R7FormDialog({
    super.key,
    this.employee,
    required this.onDataChanged,
  });

  @override
  State<R7FormDialog> createState() => _R7FormDialogState();
}

class _R7FormDialogState extends State<R7FormDialog> {
  late final Map<String, TextEditingController> header;
  late final List<Map<String, TextEditingController>> rows;

  bool _saving = false;
  bool _generatingPdf = false;
  bool _autoPopulating = false;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();

    header = {
      'companyName': TextEditingController(),
      'year': TextEditingController(
        text: DateFormat('yyyy').format(DateTime.now()),
      ),
      'tradeName': TextEditingController(),
      'financeRegistrationNumber': TextEditingController(),
      'nssfRegistrationNumber': TextEditingController(),
    };

    rows = List.generate(13, (index) {
      return {
        'employeeName': TextEditingController(),
        'personalFinanceNumber': TextEditingController(),
        'membershipNumber': TextEditingController(),
        'startDate': TextEditingController(),
        'endDate': TextEditingController(),
      };
    });

    _loadCompanyInfo();
    // Load for current year
    _loadR7ForYear(_selectedYear);
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final data = await ApiService.getCompanyInfo();
      header['companyName']?.text = data['company_name'] ?? '';
      header['tradeName']?.text = data['trade_name'] ?? '';
      header['financeRegistrationNumber']?.text =
          data['ministry_reg_number'] ?? '';
      header['nssfRegistrationNumber']?.text =
          data['social_security_number'] ?? '';
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _loadR7ForYear(int year) async {
    try {
      final data = await ApiService.getR7Annual(year);
      if (data == null) {
        // No data for this year yet — just load company info defaults
        await _loadCompanyInfo();
        // Clear all rows
        for (final row in rows) {
          row['employeeName']?.text = '';
          row['personalFinanceNumber']?.text = '';
          row['membershipNumber']?.text = '';
          row['startDate']?.text = '';
          row['endDate']?.text = '';
        }
        if (mounted) setState(() {});
        return;
      }

      header['companyName']?.text = data['company_name'] ?? '';
      header['year']?.text = data['year'] ?? '$year';
      header['tradeName']?.text = data['trade_name'] ?? '';
      header['financeRegistrationNumber']?.text =
          data['finance_registration_number'] ?? '';
      header['nssfRegistrationNumber']?.text =
          data['nssf_registration_number'] ?? '';

      final employees = (data['employees'] as List?) ?? [];
      for (int i = 0; i < rows.length && i < employees.length; i++) {
        final row = rows[i];
        final item = employees[i] as Map<String, dynamic>;
        row['employeeName']?.text = item['employee_name'] ?? '';
        row['personalFinanceNumber']?.text =
            item['personal_finance_number'] ?? '';
        row['membershipNumber']?.text = item['membership_number'] ?? '';
        row['startDate']?.text = item['start_date'] ?? '';
        row['endDate']?.text = item['end_date'] ?? '';
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to load R7 for year $year: $e');
    }
  }

  Future<void> _autoPopulateForYear(int year) async {
    setState(() => _autoPopulating = true);
    try {
      final result = await ApiService.autoPopulateR7(year);
      final count = result['employee_count'] as int? ?? 0;

      // Reload the dialog with fresh data
      await _loadR7ForYear(year);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count == 0
                  ? 'لا يوجد أجراء تركوا العمل في سنة $year'
                  : 'تم تعبئة $count أجير تلقائياً لسنة $year',
            ),
            backgroundColor: const Color(0xFF00897B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التعبئة التلقائية: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _autoPopulating = false);
    }
  }

  String _fmtRawDate(dynamic value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.isEmpty) return '';
    // DB often returns "2025-03-01T00:00:00.000" — just take the date part
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  @override
  void dispose() {
    for (final ctrl in header.values) ctrl.dispose();
    for (final row in rows) {
      for (final ctrl in row.values) ctrl.dispose();
    }
    super.dispose();
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _tfController(
    TextEditingController controller,
    String label, {
    bool isLtr = false,
    TextInputType? kb,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      textDirection: isLtr ? ui.TextDirection.ltr : ui.TextDirection.rtl,
      keyboardType: kb,
      maxLines: maxLines,
      maxLength: maxLength,
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

  Map<String, dynamic> _buildDataMap() {
    String? ne(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    return {
      'company_name': ne(header['companyName']?.text),
      'year': ne(header['year']?.text),
      'trade_name': ne(header['tradeName']?.text),
      'finance_registration_number':
          ne(header['financeRegistrationNumber']?.text),
      'nssf_registration_number': ne(header['nssfRegistrationNumber']?.text),
      'employees': rows.map((row) {
        return {
          'employee_name': ne(row['employeeName']?.text),
          'personal_finance_number': ne(row['personalFinanceNumber']?.text),
          'membership_number': ne(row['membershipNumber']?.text),
          'start_date': ne(row['startDate']?.text),
          'end_date': ne(row['endDate']?.text),
        };
      }).toList(),
    };
  }

  Future<void> _saveOnly() async {
  setState(() => _saving = true);
  try {
    await ApiService.saveR7Annual(_selectedYear, _buildDataMap());
    widget.onDataChanged();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ بيانات R7 لسنة $_selectedYear'),
        backgroundColor: const Color(0xFF00897B),
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
    if (mounted) setState(() => _saving = false);
  }
}

Future<void> _generateAndSavePdf() async {
  setState(() => _generatingPdf = true);
  try {
    debugPrint('Step 1: saving R7 annual data...');
    await ApiService.saveR7Annual(_selectedYear, _buildDataMap());
    debugPrint('Step 2: generating PDF...');
    final pdfBytes = await _generateR7Pdf();
    debugPrint('Step 3: PDF generated, size=${pdfBytes.length}, uploading...');
    final fileName =
        'r7_${_selectedYear}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await ApiService.uploadCompanyDocument(
      fileName: fileName,
      fileBytes: pdfBytes,
      mimeType: 'application/pdf',
    );
    debugPrint('Step 4: upload complete');
    widget.onDataChanged();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ ملف R7 لسنة $_selectedYear في مستندات الشركة'),
        backgroundColor: const Color(0xFF00897B),
      ),
    );
    Navigator.pop(context);
  } catch (e, stack) {
    debugPrint('R7 PDF ERROR: $e');
    debugPrint('STACK: $stack');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('فشل: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _generatingPdf = false);
  }
}

  List<String> _splitDate(String date) {
    if (date.trim().isEmpty) return ['', '', ''];
    final p = date.trim().split('-');
    if (p.length == 3) return [p[2], p[1], p[0]];
    return ['', '', ''];
  }

  Future<Uint8List> _generateR7Pdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);
    final templateData =
        await rootBundle.load('assets/r7_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    final pdf = pw.Document();
    final baseStyle = pw.TextStyle(
        font: arabicFont, fontSize: 9, color: PdfColors.blue900);
    final smallStyle = pw.TextStyle(
        font: arabicFont, fontSize: 8, color: PdfColors.blue900);
    final widgets = <pw.Widget>[];

    void l(double leftX, double y, String text,
        {required double width, pw.TextStyle? style}) {
      if (text.isEmpty) return;
      widgets.add(pw.Positioned(
        left: leftX,
        top: y,
        child: pw.Container(
          width: width,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            text,
            style: style ?? baseStyle,
            textDirection: pw.TextDirection.ltr,
            textAlign: pw.TextAlign.left,
            maxLines: 1,
          ),
        ),
      ));
    }

    String h(String key) => header[key]?.text.trim() ?? '';
    l(584, 188, h('companyName'), width: 330);
    l(206, 190, h('year'), width: 110);
    l(624, 226, h('tradeName'), width: 380);
    l(628, 266, h('financeRegistrationNumber'), width: 175);
    l(214, 264, h('nssfRegistrationNumber'), width: 255);

    // Row Y positions matching your template
    const rowYPositions = [
      430.0, 494.0, 558.0, 622.0, 686.0, 750.0, 814.0,
      878.0, 942.0, 1006.0, 1070.0, 1134.0, 1198.0
    ];

    for (int i = 0; i < 13; i++) {
      final row = rows[i];
      final y = rowYPositions[i];
      final start = _splitDate(row['startDate']?.text.trim() ?? '');
      final end = _splitDate(row['endDate']?.text.trim() ?? '');

      l(794, y, row['employeeName']?.text.trim() ?? '',
          width: 240, style: smallStyle);
      l(492, y, row['personalFinanceNumber']?.text.trim() ?? '',
          width: 165, style: smallStyle);
      l(396, y, row['membershipNumber']?.text.trim() ?? '',
          width: 120, style: smallStyle);
      l(296, y, start[0], width: 24, style: smallStyle);
      l(254, y, start[1], width: 24, style: smallStyle);
      l(214, y, start[2], width: 42, style: smallStyle);
      l(168, y, end[0], width: 24, style: smallStyle);
      l(126, y, end[1], width: 24, style: smallStyle);
      l(82, y, end[2], width: 42, style: smallStyle);
    }

    pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(1024, 1280),
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(children: [
          pw.Positioned.fill(
            child: pw.Image(templateImage,
                width: 1024, height: 1280, fit: pw.BoxFit.fill),
          ),
          ...widgets,
        ]),
      ),
    ));

    return Uint8List.fromList(await pdf.save());
  }

  Widget _buildEmployeeRow(int index) {
    final row = rows[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'السطر ${index + 1}',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8E244D),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _tfController(row['employeeName']!, 'اسم المستخدم / الأجير الثلاثي'),
            const SizedBox(height: 12),
            _row2(
              _tfController(row['personalFinanceNumber']!,
                  'رقم التسجيل الشخصي لدى وزارة المالية',
                  isLtr: true, kb: TextInputType.number, maxLength: 13),
              _tfController(row['membershipNumber']!, 'رقم الانتساب',
                  isLtr: true, kb: TextInputType.number, maxLength: 13),
            ),
            const SizedBox(height: 12),
            _row2(
              _tfController(row['startDate']!, 'تاريخ بدء العمل (YYYY-MM-DD)',
                  isLtr: true),
              _tfController(row['endDate']!, 'تاريخ انتهاء العمل (YYYY-MM-DD)',
                  isLtr: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820, maxHeight: 900),
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E244D), Color(0xFFB23A5B)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'نموذج R7',
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

              // ── Body ─────────────────────────────────────────────
              // ── Body ─────────────────────────────────────────────
Expanded(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        _section('بيانات المؤسسة'),
        _row2(
          _tfController(header['companyName']!,
              'اسم الشركة / المؤسسة'),
          _tfController(header['year']!, 'عن أعمال سنة',
              isLtr: true),
        ),
        const SizedBox(height: 12),
        _row2(
          _tfController(header['tradeName']!, 'الشهرة التجارية'),
          _tfController(header['financeRegistrationNumber']!,
              'رقم التسجيل لدى وزارة المالية',
              isLtr: true, kb: TextInputType.number),
        ),
        const SizedBox(height: 12),
        _tfController(
          header['nssfRegistrationNumber']!,
          'رقم التسجيل لدى الصندوق الوطني للضمان الاجتماعي',
          isLtr: true, kb: TextInputType.number,
        ),

        // ── Employee rows section ─────────────────────
        _section('بيانات الأجراء - 13 أسطر'),
        ...List.generate(13, _buildEmployeeRow),

        // ── Year selector + auto-populate AFTER the 13 rows ──
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF0D47A1).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Color(0xFF0D47A1), size: 18),
                const SizedBox(width: 10),
                const Text('السنة:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: List.generate(10, (i) {
                    final y = DateTime.now().year - i;
                    return DropdownMenuItem(
                      value: y,
                      child: Text('$y'),
                    );
                  }),
                  onChanged: _autoPopulating || _saving || _generatingPdf
                      ? null
                      : (y) {
                          if (y == null) return;
                          setState(() => _selectedYear = y);
                          _loadR7ForYear(y);
                        },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _autoPopulating || _saving || _generatingPdf
                        ? null
                        : () => _autoPopulateForYear(_selectedYear),
                    icon: _autoPopulating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(
                      _autoPopulating
                          ? 'جاري التعبئة...'
                          : 'تعبئة تلقائية لسنة $_selectedYear',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D47A1),
                      side: const BorderSide(color: Color(0xFF0D47A1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),

              // ── Footer ───────────────────────────────────────────
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
                      label: Text(_saving ? 'جاري الحفظ...' : 'حفظ فقط'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed:
                          _saving || _generatingPdf ? null : _generateAndSavePdf,
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
                      label: Text(
                        _generatingPdf ? 'جاري الإنشاء...' : 'حفظ + إنشاء PDF',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8E244D),
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