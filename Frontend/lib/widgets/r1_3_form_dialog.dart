import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../services/api_service.dart';

class R1_3FormDialog extends StatefulWidget {
  final VoidCallback onDataChanged;
  final int employeeCount;

  const R1_3FormDialog({
    super.key,
    required this.onDataChanged,
    this.employeeCount = 1,
  });

  @override
  State<R1_3FormDialog> createState() => _R1_3FormDialogState();
}

class _R1_3FormDialogState extends State<R1_3FormDialog> {
  final Map<String, TextEditingController> c = {};
  bool _loading = true;
  bool _saving = false;
  bool _generatingPdf = false;

  String _fmtDt(DateTime? d) =>
      d != null ? DateFormat('yyyy-MM-dd').format(d) : '';

  @override
  void initState() {
    super.initState();

    for (final k in [
      'companyName',
      'tradeName',
      'ministryReg',
      'socialSecurity',
      'gov',
      'district',
      'area',
      'neighborhood',
      'street',
      'cadastralArea',
      'property',
      'building',
      'floor',
      'phone1',
      'phone2',
      'fax',
      'poBoxNumber',
      'poBoxArea',
      'email',
      'contactName',
      'contactTitle',
      'contactPhone',
      'contactFax',
      'employeeCount',
      'submittedByName',
      'submittedByTitle',
      'submittedDate',
      'bookNumber',
      'bookSubmittedDate',
    ]) {
      c[k] = TextEditingController();
    }

    c['employeeCount']!.text = widget.employeeCount.toString();
    c['submittedDate']!.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final data = await ApiService.getCompanyInfo();

      c['companyName']!.text = data['company_name'] ?? '';
      c['tradeName']!.text = data['trade_name'] ?? '';
      c['ministryReg']!.text = data['ministry_reg_number'] ?? '';
      c['socialSecurity']!.text = data['social_security_number'] ?? '';

      c['gov']!.text = data['governorate'] ?? '';
      c['district']!.text = data['district'] ?? '';
      c['area']!.text = data['area'] ?? '';
      c['neighborhood']!.text = data['neighborhood'] ?? '';
      c['street']!.text = data['street'] ?? '';
      c['cadastralArea']!.text = data['cadastral_area'] ?? '';
      c['property']!.text = data['property_number'] ?? '';
      c['building']!.text = data['building'] ?? '';
      c['floor']!.text = data['floor'] ?? '';
      c['phone1']!.text = data['phone1'] ?? '';
      c['phone2']!.text = data['phone2'] ?? '';
      c['fax']!.text = data['fax'] ?? '';
      c['poBoxNumber']!.text = data['po_box_number'] ?? '';
      c['poBoxArea']!.text = data['po_box_area'] ?? '';
      c['email']!.text = data['email'] ?? '';

      c['contactName']!.text = data['contact_name'] ?? '';
      c['contactTitle']!.text = data['contact_title'] ?? '';
      c['contactPhone']!.text = data['contact_phone'] ?? '';
      c['contactFax']!.text = data['contact_fax'] ?? '';

      c['submittedByName']!.text = data['submitted_by_name'] ?? '';
      c['submittedByTitle']!.text = data['submitted_by_title'] ?? '';
      c['submittedDate']!.text =
          data['submitted_date'] ?? c['submittedDate']!.text;

      c['bookNumber']!.text = data['book_number'] ?? '';
      c['bookSubmittedDate']!.text = data['book_submitted_date'] ?? '';
    } catch (_) {
      // leave defaults
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

  Map<String, dynamic> _buildPayload() {
    return {
      'company_name': _ne(c['companyName']!.text),
      'trade_name': _ne(c['tradeName']!.text),
      'ministry_reg_number': _ne(c['ministryReg']!.text),
      'social_security_number': _ne(c['socialSecurity']!.text),

      'governorate': _ne(c['gov']!.text),
      'district': _ne(c['district']!.text),
      'area': _ne(c['area']!.text),
      'neighborhood': _ne(c['neighborhood']!.text),
      'street': _ne(c['street']!.text),
      'cadastral_area': _ne(c['cadastralArea']!.text),
      'property_number': _ne(c['property']!.text),
      'building': _ne(c['building']!.text),
      'floor': _ne(c['floor']!.text),
      'phone1': _ne(c['phone1']!.text),
      'phone2': _ne(c['phone2']!.text),
      'fax': _ne(c['fax']!.text),
      'po_box_number': _ne(c['poBoxNumber']!.text),
      'po_box_area': _ne(c['poBoxArea']!.text),
      'email': _ne(c['email']!.text),

      'contact_name': _ne(c['contactName']!.text),
      'contact_title': _ne(c['contactTitle']!.text),
      'contact_phone': _ne(c['contactPhone']!.text),
      'contact_fax': _ne(c['contactFax']!.text),

      'attached_requests_count': int.tryParse(c['employeeCount']!.text.trim()),

      'submitted_by_name': _ne(c['submittedByName']!.text),
      'submitted_by_title': _ne(c['submittedByTitle']!.text),
      'submitted_date': _ne(c['submittedDate']!.text),

      // admin-only fields
      'book_number': _ne(c['bookNumber']!.text),
      'book_submitted_date': _ne(c['bookSubmittedDate']!.text),
    };
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    try {
      await ApiService.saveCompanyInfo(_buildPayload());
      widget.onDataChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('R3-1 data saved!'),
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
  if (mounted) setState(() => _generatingPdf = true);

  try {
    await ApiService.saveCompanyInfo(_buildPayload());

    final pdfBytes = await _generateR1_3Pdf();
final company = c['companyName']!.text.replaceAll(' ', '');
final fileName = '${company}_${widget.employeeCount}_R3-1_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
await ApiService.uploadCompanyDocument(
  fileName: fileName,
  fileBytes: pdfBytes,
  mimeType: 'application/pdf',
);

    // Option 1: if your ApiService already has a real upload method, call it here.
    // Example:
    // await ApiService.uploadCompanyDocument(
    //   fileName: fileName,
    //   fileBytes: pdfBytes,
    //   mimeType: 'application/pdf',
    // );

    widget.onDataChanged();

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF "$fileName" generated successfully!'),
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

  Future<Uint8List> _generateR1_3Pdf() async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final templateData = await rootBundle.load('assets/r1_3_template_blank.png');
    final templateImage = pw.MemoryImage(templateData.buffer.asUint8List());

    String v(String key) => c[key]?.text.trim() ?? '';

    List<String> pd(String date) {
      if (date.isEmpty) return ['', '', ''];
      final p = date.split('-');
      return p.length == 3 ? [p[2], p[1], p[0]] : ['', '', ''];
    }

    final submittedDate = pd(v('submittedDate'));
    final bookSubmittedDate = pd(v('bookSubmittedDate'));

    const sx = 595.28 / 1024.0;
    const sy = 841.89 / 1280.0;

    final ts = pw.TextStyle(
      font: arabicFont,
      fontSize: 9,
      color: PdfColors.blue900,
    );

    final List<pw.Widget> o = [];

    void r(double px, double py, String text) {
      if (text.isEmpty) return;
      o.add(
        pw.Positioned(
          left: px * sx,
          top: py * sy,
          child: pw.Text(
            text,
            style: ts,
            textDirection: pw.TextDirection.rtl,
          ),
        ),
      );
    }

    void l(double px, double py, String text) {
      if (text.isEmpty) return;
      o.add(
        pw.Positioned(
          left: px * sx,
          top: py * sy,
          child: pw.Text(
            text,
            style: ts,
            textDirection: pw.TextDirection.ltr,
          ),
        ),
      );
    }

    // ─────────────────────────────────────────
    // TOP SECTION — company info
    // Adjust these positions against your blank template
    // ─────────────────────────────────────────
    r(654, 182, v('companyName'));      // اسم الشركة/المؤسسة
    r(218, 184, v('tradeName'));        // الشهرة التجارية
    l(576, 244, v('ministryReg'));      // رقم التسجيل لدى وزارة المالية
    l(128, 240, v('socialSecurity'));   // رقم لدى الضمان الاجتماعي

    // ─────────────────────────────────────────
    // ADDRESS SECTION
    // ─────────────────────────────────────────
    r(848, 368, v('gov'));              // المحافظة
    r(614, 370, v('district'));         // القضاء
    r(370, 368, v('area'));             // منطقة - بلدة
    r(136, 368, v('neighborhood'));     // الحي

    r(788, 414, v('street'));           // الشارع
    r(390, 420, v('cadastralArea'));    // المنطقة العقارية
    r(70, 416, v('property'));         // رقم العقار / القسم

    r(802, 456, v('building'));         // المبنى
    r(560, 460, v('floor'));            // الطابق
    l(350, 458, v('phone1'));           // هاتف
    l(112, 460, v('phone2'));           // هاتف

    l(112, 502  , v('fax'));              // فاكس
    l(776, 496, v('poBoxNumber'));      // صندوق بريد رقم
    r(522, 496, v('poBoxArea'));        // المنطقة

    l(564, 536, v('email'));            // البريد الإلكتروني

    // ─────────────────────────────────────────
    // CONTACT PERSON
    // ─────────────────────────────────────────
    r(730, 656, v('contactName'));      // الاسم الكامل
    r(218, 654, v('contactTitle'));     // الصفة
    l(810, 700, v('contactPhone'));     // هاتف
    l(540, 700, v('contactFax'));        // فاكس

    // ─────────────────────────────────────────
    // ATTACHED REQUEST COUNT
    // ─────────────────────────────────────────
    l(448, 836, v('employeeCount'));

    // ─────────────────────────────────────────
    // SUBMITTED BY (مقدم الكتاب)
    // No signature text added intentionally
    // ─────────────────────────────────────────
    r(784, 960, v('submittedByName'));      // الاسم
    r(238, 960, v('submittedByTitle'));     // الصفة

    l(884, 1054, submittedDate[0]);          // اليوم
    l(820, 1054, submittedDate[1]);          // الشهر
    l(752, 1054, submittedDate[2]);          // السنة

    // ─────────────────────────────────────────
    // ADMIN SECTION (optional)
    // Keep blank unless needed
    // ─────────────────────────────────────────
    l(628, 1196, v('bookNumber'));          // رقم الكتاب
    l(216, 1194, bookSubmittedDate[0]);     // اليوم
    l(152, 1194, bookSubmittedDate[1]);     // الشهر
    l(94, 1194, bookSubmittedDate[2]);     // السنة

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(templateImage, fit: pw.BoxFit.fill),
              ),
              ...o,
            ],
          ),
        ),
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
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
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
                  color: const Color(0xFF2E7D32),
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
                    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.business_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كتاب طلب تسجيل مستخدمين/أجراء',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'R3-1 — Company Registration Form',
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
                      row2(
                        tf('companyName', 'إسم الشركة/المؤسسة'),
                        tf('tradeName', 'الشهرة التجارية'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('ministryReg', 'رقم التسجيل (وزارة المالية)', isLtr: true),
                        tf('socialSecurity', 'رقم الشركة/المؤسسة (الضمان الاجتماعي)', isLtr: true),
                      ),

                      section('عنوان الشركة/المؤسسة'),
                      row2(tf('gov', 'المحافظة'), tf('district', 'القضاء')),
                      const SizedBox(height: 12),
                      row2(tf('area', 'منطقة - بلدة'), tf('neighborhood', 'الحي')),
                      const SizedBox(height: 12),
                      row2(tf('street', 'الشارع'), tf('cadastralArea', 'المنطقة العقارية')),
                      const SizedBox(height: 12),
                      row2(
                        tf('property', 'رقم العقار / القسم', isLtr: true),
                        tf('building', 'المبنى'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('floor', 'الطابق'),
                        tf('phone1', 'هاتف ١', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('phone2', 'هاتف ٢', isLtr: true),
                        tf('fax', 'فاكس', isLtr: true),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('poBoxNumber', 'صندوق بريد رقم', isLtr: true),
                        tf('poBoxArea', 'المنطقة'),
                      ),
                      const SizedBox(height: 12),
                      tf('email', 'البريد الإلكتروني (e-mail)', isLtr: true),

                      section('جهة الاتصال'),
                      row2(
                        tf('contactName', 'الاسم الكامل'),
                        tf('contactTitle', 'الصفة'),
                      ),
                      const SizedBox(height: 12),
                      row2(
                        tf('contactPhone', 'هاتف', isLtr: true),
                        tf('contactFax', 'فاكس', isLtr: true),
                      ),

                      section('عدد الطلبات'),
                      tf(
                        'employeeCount',
                        'عدد طلبات تسجيل المستخدمين/الأجراء المرفقة',
                        isLtr: true,
                        kb: TextInputType.number,
                      ),

                      section('مقدم الكتاب'),
                      row2(
                        tf('submittedByName', 'الاسم'),
                        tf('submittedByTitle', 'الصفة'),
                      ),
                      const SizedBox(height: 12),
                      tf(
                        'submittedDate',
                        'التاريخ',
                        isLtr: true,
                        hint: 'YYYY-MM-DD',
                      ),

                      section('خاص بالإدارة (اختياري)'),
                      row2(
                        tf('bookNumber', 'رقم الكتاب', isLtr: true),
                        tf(
                          'bookSubmittedDate',
                          'تاريخ تقديم الكتاب',
                          isLtr: true,
                          hint: 'YYYY-MM-DD',
                        ),
                      ),
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
                      onPressed:
                          _saving || _generatingPdf ? null : _saveAndGeneratePdf,
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
                        backgroundColor: const Color(0xFF2E7D32),
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