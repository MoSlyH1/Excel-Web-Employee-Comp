import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/employee.dart';
import '../services/api_service.dart';
import 'r1_3_form_dialog.dart';
import 'r3_form_dialog.dart';
import 'r4_form_dialog.dart';
import 'e3lam_form_dialog.dart';
class EmployeeDetailDialog extends StatelessWidget {
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

  String _fmt(DateTime? d) =>
      d != null ? DateFormat('dd MMM yyyy').format(d) : '—';

  Future<void> _deleteEmployee(BuildContext context) async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${employee.fullName}?\n\n'
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
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 48,
        ),
        title: const Text('Are you absolutely sure?'),
        content: Text(
          'This action CANNOT be undone.\n\n'
          'You are about to permanently delete:\n'
          '• ${employee.fullName} (${employee.employeeId})\n'
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
      await ApiService.deleteEmployee(employee.id!);

      if (context.mounted) {
        Navigator.pop(context);
        onDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${employee.fullName} deleted'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openR3Form(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => R1_3FormDialog(
        onDataChanged: onDataChanged,
        employeeCount: 1,
      ),
    );
  }

  void _openR3EmployeeForm(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => R3FormDialog(
        employee: employee,
        onDataChanged: onDataChanged,
      ),
    );
  }

  void _openR4Form(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => R4FormDialog(
        employee: employee,
        onDataChanged: onDataChanged,
      ),
    );
  }
    void _openE3lamForm(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => E3lamFormDialog(
        employee: employee,
        onDataChanged: onDataChanged,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final e = employee;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      e.fullName.isNotEmpty ? e.fullName[0].toUpperCase() : '?',
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
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(
                      'Personal Info',
                      [
                        _f('Employee ID', e.employeeId),
                        _f('Nationality', e.nationality),
                        _f('Email', e.email),
                        _f('Phone', e.phone),
                        _f('Bank Account', e.bankAccountNb),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _section(
                      'Employment',
                      [
                        _f('Contract Type', e.contractType),
                        _f('Department', e.department),
                        _f('Position', e.jobPosition),
                        _f('Wage Type', e.wageType),
                        _f('Basic Salary', e.basicSalary?.toStringAsFixed(0)),
                        _f(
                          'Other Allowances',
                          e.otherAllowances?.toStringAsFixed(0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _section(
                      'Dates',
                      [
                        _f('Joining Date', _fmt(e.joiningDate)),
                        _f('Start Date', _fmt(e.startDate)),
                        _f('End Date', _fmt(e.endDate)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    InkWell(
                      onTap: onOpenDocs,
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
                            const Icon(
                              Icons.folder_open_rounded,
                              color: Color(0xFF00897B),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Documents',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '$docCount file(s) attached',
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

InkWell(
  onTap: () => _openE3lamForm(context),
  borderRadius: BorderRadius.circular(12),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF8E244D).withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFF8E244D).withOpacity(0.2),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8E244D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.assignment_rounded,
            color: Color(0xFF8E244D),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'إعلام عن ترك أجير عمله في المؤسسة',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Color(0xFF8E244D),
        ),
      ],
    ),
  ),
),
                    const SizedBox(height: 12),

                    // R3-1 COMPANY LETTER
                    InkWell(
                      onTap: () => _openR3Form(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.business_rounded,
                                color: Color(0xFF2E7D32),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'كتاب طلب تسجيل مستخدمين/أجراء (R3-1)',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Fill company registration letter form',
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
                              color: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // R3 EMPLOYEE FORM
                    InkWell(
                      onTap: () => _openR3EmployeeForm(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6A1B9A).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A1B9A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.assignment_ind_rounded,
                                color: Color(0xFF6A1B9A),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'طلب تسجيل مستخدم/أجير جديد (R3)',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Fill employee R3 form and save to employee + company docs',
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
                              color: Color(0xFF6A1B9A),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () => _openR4Form(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0D47A1).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D47A1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: Color(0xFF0D47A1),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'بيان معلومات المستخدم (R4)',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Fill R4 government form data',
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
                              color: Color(0xFF0D47A1),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteEmployee(context),
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          size: 20,
                        ),
                        label: const Text('Delete Employee'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
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
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: children,
        ),
      ],
    );
  }

  Widget _f(String label, String? value) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            value ?? '—',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}