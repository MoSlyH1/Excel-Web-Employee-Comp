import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/employee.dart';
import '../services/api_service.dart';

class EditEmployeeDialog extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDataChanged;

  const EditEmployeeDialog({
    super.key,
    required this.employee,
    required this.onDataChanged,
  });

  @override
  State<EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<EditEmployeeDialog> {
  late final Map<String, TextEditingController> c;

  String? contractTypeVal;
  String? wageTypeVal;

  bool _saving = false;

  static String _fmtDt(DateTime? d) =>
      d != null ? DateFormat('yyyy-MM-dd').format(d) : '';

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    c = {
      // ── Identity ─────────────────────────────────────────────
      'employeeId':    TextEditingController(text: e.employeeId),
      'fullName':      TextEditingController(text: e.fullName),
      'firstName':     TextEditingController(text: e.firstName ?? ''),
      'lastName':      TextEditingController(text: e.lastName ?? ''),
      'fatherName':    TextEditingController(text: e.fatherName ?? ''),
      'motherName':    TextEditingController(text: e.motherName ?? ''),
      'nationality':   TextEditingController(text: e.nationality ?? ''),
      'email':         TextEditingController(text: e.email ?? ''),
      'phone':         TextEditingController(text: e.phone ?? ''),
      'phone2':        TextEditingController(text: e.phone2 ?? ''),
      'bankAccountNb': TextEditingController(text: e.bankAccountNb ?? ''),

      // ── Employment ───────────────────────────────────────────
      'department':      TextEditingController(text: e.department ?? ''),
      'jobPosition':     TextEditingController(text: e.jobPosition ?? ''),
      'basicSalary':     TextEditingController(
          text: e.basicSalary != null ? e.basicSalary!.toStringAsFixed(0) : ''),
      'otherAllowances': TextEditingController(
          text: e.otherAllowances != null
              ? e.otherAllowances!.toStringAsFixed(0)
              : ''),

      // ── Dates ────────────────────────────────────────────────
      'joiningDate': TextEditingController(text: _fmtDt(e.joiningDate)),
      'startDate':   TextEditingController(text: _fmtDt(e.startDate)),
      'endDate':     TextEditingController(text: _fmtDt(e.endDate)),
      'hiringDate':  TextEditingController(text: _fmtDt(e.hiringDate)),
      'leftDate':    TextEditingController(text: _fmtDt(e.leftDate)),
      'hiring2Date': TextEditingController(text: _fmtDt(e.hiring2Date)),
      'left2Date':   TextEditingController(text: _fmtDt(e.left2Date)),
    };

    contractTypeVal = e.contractType;
    wageTypeVal     = e.wageType;
  }

  @override
  void dispose() {
    for (final ctrl in c.values) ctrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    String? ne(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    double? nd(String? v) =>
        (v == null || v.trim().isEmpty) ? null : double.tryParse(v.trim());

    return {
      'employee_id':      ne(c['employeeId']!.text),
      'full_name':        ne(c['fullName']!.text) ?? widget.employee.fullName,
      'first_name':       ne(c['firstName']!.text),
      'last_name':        ne(c['lastName']!.text),
      'father_name':      ne(c['fatherName']!.text),
      'mother_name':      ne(c['motherName']!.text),
      'nationality':      ne(c['nationality']!.text),
      'email':            ne(c['email']!.text),
      'phone':            ne(c['phone']!.text),
      'phone2':           ne(c['phone2']!.text),
      'bank_account_nb':  ne(c['bankAccountNb']!.text),
      'department':       ne(c['department']!.text),
      'job_position':     ne(c['jobPosition']!.text),
      'contract_type':    contractTypeVal,
      'wage_type':        wageTypeVal,
      'basic_salary':     nd(c['basicSalary']!.text),
      'other_allowances': nd(c['otherAllowances']!.text),
      'joining_date':     ne(c['joiningDate']!.text),
      'start_date':       ne(c['startDate']!.text),
      'end_date':         ne(c['endDate']!.text),
      'hiring_date':      ne(c['hiringDate']!.text),
      'left_date':        ne(c['leftDate']!.text),
      'hiring_2_date':    ne(c['hiring2Date']!.text),
      'left_2_date':      ne(c['left2Date']!.text),
    };
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService.updateEmployee(widget.employee.id!, _buildPayload());
      widget.onDataChanged();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee updated successfully'),
            backgroundColor: Color(0xFF00897B),
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $err'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _saving = false);
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    InputDecoration dec(String label, {String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        );

    Widget tf(String key, String label,
        {TextInputType? kb, String? hint, bool enabled = true}) {
      return TextField(
        controller: c[key],
        keyboardType: kb,
        enabled: enabled,
        decoration: dec(label, hint: hint),
      );
    }

    Widget row2(Widget a, Widget b) => Row(children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ]);

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
                  color: const Color(0xFF0D47A1),
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ]),
        );

    Widget dd(String label, String? val, List<String> opts,
        void Function(String?) onChange) {
      return DropdownButtonFormField<String>(
        value: val,
        decoration: dec(label),
        items: [
          const DropdownMenuItem(value: null, child: Text('—')),
          ...opts.map((o) => DropdownMenuItem(value: o, child: Text(o))),
        ],
        onChanged: onChange,
      );
    }

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 680, maxHeight: 820),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(children: [
                const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Employee',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.employee.fullName,
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

            // ── Body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Identity ────────────────────────────────
                    section('Identity'),
                    row2(
                      tf('employeeId', 'Employee ID'),
                      tf('nationality', 'Nationality'),
                    ),
                    const SizedBox(height: 12),
                    row2(
                      tf('firstName', 'First Name'),
                      tf('lastName', 'Last Name (Surname)'),
                    ),
                    const SizedBox(height: 12),
                    row2(
                      tf('fatherName', 'Father Name'),
                      tf('motherName', 'Mother Name'),
                    ),
                    const SizedBox(height: 12),
                    // Full name auto-derived but editable
                    tf('fullName', 'Full Name (as displayed)'),

                    // ── Contact ─────────────────────────────────
                    section('Contact'),
                    row2(
                      tf('email', 'Email',
                          kb: TextInputType.emailAddress),
                      tf('phone', 'Phone', kb: TextInputType.phone),
                    ),
                    const SizedBox(height: 12),
                    row2(
                      tf('phone2', 'Phone 2', kb: TextInputType.phone),
                      tf('bankAccountNb', 'Bank Account Number',
                          kb: TextInputType.number),
                    ),

                    // ── Employment ──────────────────────────────
                    section('Employment'),
                    row2(
                      tf('department', 'Department'),
                      tf('jobPosition', 'Job Position'),
                    ),
                    const SizedBox(height: 12),
                    row2(
                      dd(
                        'Contract Type',
                        contractTypeVal,
                        ['Monthly', 'Part time', 'Seasonal', 'Temporary'],
                        (v) => setState(() => contractTypeVal = v),
                      ),
                      dd(
                        'Wage Type',
                        wageTypeVal,
                        ['full time', 'daily', 'hourly', 'Part time'],
                        (v) => setState(() => wageTypeVal = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    row2(
                      tf('basicSalary', 'Basic Salary',
                          kb: TextInputType.number),
                      tf('otherAllowances', 'Other Allowances',
                          kb: TextInputType.number),
                    ),

                    // ── Dates ───────────────────────────────────
                    section('Dates'),
                    row2(
                      tf('joiningDate', 'Joining Date',
                          hint: 'YYYY-MM-DD'),
                      tf('startDate', 'Start Date (NSSF)',
                          hint: 'YYYY-MM-DD'),
                    ),
                    const SizedBox(height: 12),
                    row2(
                      tf('hiringDate', 'Hiring Date',
                          hint: 'YYYY-MM-DD'),
                      tf('leftDate', 'Left Date',
                          hint: 'YYYY-MM-DD'),
                    ),
                    const SizedBox(height: 12),
                    row2(
                      tf('endDate', 'End Date',
                          hint: 'YYYY-MM-DD'),
                      Container(),
                    ),

                    // ── Second period (if any) ──────────────────
                    section('Second Employment Period'),
                    row2(
                      tf('hiring2Date', 'Hiring Date 2',
                          hint: 'YYYY-MM-DD'),
                      tf('left2Date', 'Left Date 2',
                          hint: 'YYYY-MM-DD'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(_saving ? 'Saving...' : 'Save Changes'),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}