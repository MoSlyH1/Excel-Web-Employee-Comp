import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/employee.dart';
import '../services/api_service.dart';
import 'r1_3_form_dialog.dart';
import 'r3_form_dialog.dart';
import 'r4_form_dialog.dart';
import 'e3lam_form_dialog.dart';
import 'r7_form_dialog.dart';
import 'tasryh_zawjaa_form_dialog.dart';
import 'declaration_employee_form_dialog.dart';
import 'edit_employee_dialog.dart';
import 'efada_form_dialog.dart';
import 'efadet_3amal_form_dialog.dart'; // ← NEW

class EmployeeDetailDialog extends StatefulWidget {
  final Employee employee;
  final int docCount;
  final VoidCallback onOpenDocs;
  final VoidCallback onDataChanged;

  const EmployeeDetailDialog({
    super.key,
    required this.employee,
    required this.docCount,
    required this.onOpenDocs,
    required this.onDataChanged,
  });

  @override
  State<EmployeeDetailDialog> createState() => _EmployeeDetailDialogState();
}

class _EmployeeDetailDialogState extends State<EmployeeDetailDialog> {
  bool _autoGenerating = false;

  String _fmt(DateTime? d) =>
      d != null ? DateFormat('dd MMM yyyy').format(d) : '—';

  Employee get e => widget.employee;

  bool get _hasEndDate => e.endDate != null;

  Future<void> _autoGenerateE3lam() async {
    if (e.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _autoGenerating = true);

    try {
      await ApiService.autoGenerateE3lam(e.id!);
      final fresh = await ApiService.getEmployee(e.id!);
      final pdfBytes = await generateE3lamPdfFromEmployee(fresh);

      final fileName =
          'e3lam_auto_${e.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await ApiService.uploadDocuments(
        employeeId: e.id!,
        fileNames: [fileName],
        fileBytes: [pdfBytes],
        mimeTypes: ['application/pdf'],
      );

      widget.onDataChanged();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ E3lam PDF generated: $fileName'),
          backgroundColor: const Color(0xFF00897B),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E3lam auto-generation failed: $err'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _autoGenerating = false);
    }
  }

  Future<void> _deleteEmployee(BuildContext context) async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${e.fullName}?\n\n'
          'This will also delete all their uploaded documents.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.red, size: 48),
        title: const Text('Are you absolutely sure?'),
        content: Text(
          'This action CANNOT be undone.\n\n'
          'You are about to permanently delete:\n'
          '• ${e.fullName} (${e.employeeId})\n'
          '• All associated documents',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, go back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );

    if (secondConfirm != true) return;

    try {
      await ApiService.deleteEmployee(e.id!);
      if (context.mounted) {
        Navigator.pop(context);
        widget.onDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.fullName} deleted'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $err'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Navigation helpers ─────────────────────────────────────────
  void _openR3Form(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => R1_3FormDialog(
        onDataChanged: widget.onDataChanged,
        employeeCount: 1,
      ),
    );
  }

  void _openR3EmployeeForm(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => R3FormDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  void _openR4Form(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => R4FormDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  void _openE3lamForm(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => E3lamFormDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  void _openR7Form(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => R7FormDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  void _openTasreehZawjaForm(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => TasreehZawjaFormDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  void _openDeclarationEmployeeForm(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => DeclarationEmployeeFormDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  void _openEfadaForm(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => EfadaFormDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  // ── NEW ────────────────────────────────────────────────────────
  void _openEfadetAmalForm(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => EfadetAmalFormDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  void _openEditEmployee(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => EditEmployeeDialog(
        employee: e,
        onDataChanged: widget.onDataChanged,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Text(
                      e.fullName.isNotEmpty
                          ? e.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.fullName,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${e.jobPosition ?? 'No position'} · ${e.department ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: () => _openEditEmployee(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('Personal Info', [
                      _f('Employee ID', e.employeeId),
                      _f('Nationality', e.nationality),
                      _f('Email', e.email),
                      _f('Phone', e.phone),
                      _f('Bank Account', e.bankAccountNb),
                    ]),
                    const SizedBox(height: 20),
                    _section('Employment', [
                      _f('Contract Type', e.contractType),
                      _f('Department', e.department),
                      _f('Position', e.jobPosition),
                      _f('Wage Type', e.wageType),
                      _f('Basic Salary', e.basicSalary?.toStringAsFixed(0)),
                      _f('Other Allowances',
                          e.otherAllowances?.toStringAsFixed(0)),
                    ]),
                    const SizedBox(height: 20),
                    _section('Dates', [
                      _f('Joining Date', _fmt(e.joiningDate)),
                      _f('Start Date', _fmt(e.startDate)),
                      _f('End Date', _fmt(e.endDate)),
                    ]),
                    const SizedBox(height: 20),

                    // ── Auto E3lam banner ──────────────────────
                    if (_hasEndDate) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E244D).withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8E244D).withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E244D).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF8E244D),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'إعلام — توليد تلقائي',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'End date detected · Generate E3lam PDF automatically',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _autoGenerating
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF8E244D),
                                    ),
                                  )
                                : FilledButton(
                                    onPressed: _autoGenerateE3lam,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF8E244D),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Generate',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Documents tile ─────────────────────────
                    InkWell(
                      onTap: widget.onOpenDocs,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00897B).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.folder_open_rounded,
                                color: Color(0xFF00897B)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Documents',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${widget.docCount} file(s) attached',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Color(0xFF00897B),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Form tiles ────────────────────────────
                    _formTile(
                      color: const Color(0xFF8E244D),
                      icon: Icons.assignment_rounded,
                      title: 'إعلام عن ترك أجير عمله في المؤسسة',
                      subtitle: 'Open form to review and edit before saving',
                      onTap: () => _openE3lamForm(context),
                    ),
                    const SizedBox(height: 12),

                    _formTile(
                      color: const Color(0xFF2E7D32),
                      icon: Icons.business_rounded,
                      title: 'كتاب طلب تسجيل مستخدمين/أجراء (R3-1)',
                      subtitle: 'Fill company registration letter form',
                      onTap: () => _openR3Form(context),
                    ),
                    const SizedBox(height: 12),

                    _formTile(
                      color: const Color(0xFF6A1B9A),
                      icon: Icons.assignment_ind_rounded,
                      title: 'طلب تسجيل مستخدم/أجير جديد (R3)',
                      subtitle: 'Fill employee R3 form and save to docs',
                      onTap: () => _openR3EmployeeForm(context),
                    ),
                    const SizedBox(height: 12),

                    _formTile(
                      color: const Color(0xFF0D47A1),
                      icon: Icons.description_rounded,
                      title: 'بيان معلومات المستخدم (R4)',
                      subtitle: 'Fill R4 government form data',
                      onTap: () => _openR4Form(context),
                    ),
                    const SizedBox(height: 12),

                    _formTile(
                      color: const Color(0xFFEF6C00),
                      icon: Icons.table_chart_rounded,
                      title:
                          'كشف إجمالي بالمستخدمين الذين تركوا العمل (R7)',
                      subtitle:
                          'Fill R7 form and save PDF to company documents',
                      onTap: () => _openR7Form(context),
                    ),
                    const SizedBox(height: 12),

                    _formTile(
                      color: const Color(0xFF1B5E20),
                      icon: Icons.family_restroom_rounded,
                      title: 'تصريح عن الزوجة (CNSS 485 A)',
                      subtitle: 'Fill spouse declaration form and save PDF',
                      onTap: () => _openTasreehZawjaForm(context),
                    ),
                    const SizedBox(height: 12),

                    _formTile(
                      color: const Color(0xFF4A148C),
                      icon: Icons.badge_rounded,
                      title: 'تصريح باستخدام أجير (CNSS-2 AA)',
                      subtitle:
                          'Fill employee hiring declaration form and save PDF',
                      onTap: () => _openDeclarationEmployeeForm(context),
                    ),
                    const SizedBox(height: 12),

                    _formTile(
                      color: const Color(0xFF006064),
                      icon: Icons.medical_information_rounded,
                      title: 'إفادة عمل (CNSS 2M)',
                      subtitle:
                          'Fill work illness declaration and save PDF',
                      onTap: () => _openEfadaForm(context),
                    ),
                    const SizedBox(height: 12),

                    // ── NEW ────────────────────────────────────
                    _formTile(
                      color: const Color(0xFF1A237E),
                      icon: Icons.verified_user_rounded,
                      title: 'إفادة عمل وراتب (CNSS 489)',
                      subtitle:
                          'Fill work & salary certificate and save PDF',
                      onTap: () => _openEfadetAmalForm(context),
                    ),

                    const SizedBox(height: 16),

                    // ── Delete ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteEmployee(context),
                        icon: const Icon(Icons.delete_forever_rounded,
                            size: 20),
                        label: const Text('Delete Employee'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  Widget _formTile({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 16, runSpacing: 12, children: children),
      ],
    );
  }

  Widget _f(String label, String? value) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(
            value ?? '—',
            style:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}