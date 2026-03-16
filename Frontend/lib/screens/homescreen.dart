import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../models/employee.dart';
import '../services/api_service.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/document_panel.dart';
import '../../widgets/employee_detail_dialog.dart';
import '../../widgets/stats_bar.dart';
import '../../widgets/company_documents_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  Map<int, int> _docCounts = {};
  bool _isLoading = true;
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  int? _selectedEmployeeId;
  int _companyDocCount = 0;
  bool _showCompanyDocs = false;
  String _sortColumn = 'full_name';
  bool _sortAscending = true;

  final List<_ColumnConfig> _columns = [
    _ColumnConfig('employee_id', 'ID', 100),
    _ColumnConfig('full_name', 'Employee Name', 180),
    _ColumnConfig('department', 'Dept', 100),
    _ColumnConfig('job_position', 'Position', 180),
    _ColumnConfig('nationality', 'Nationality', 120),
    _ColumnConfig('email', 'Email', 220),
    _ColumnConfig('phone', 'Phone', 130),
    _ColumnConfig('contract_type', 'Contract', 100),
    _ColumnConfig('joining_date', 'Joining Date', 120),
    _ColumnConfig('start_date', 'Start Date', 120),
    _ColumnConfig('wage_type', 'Wage Type', 110),
    _ColumnConfig('documents', 'Docs', 80),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCompanyDocCount();
  }
  Future<void> _loadCompanyDocCount() async {
  try {
    final docs = await ApiService.getCompanyDocuments();
    if (!mounted) return;
    setState(() {
      _companyDocCount = docs.length;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _companyDocCount = 0;
    });
  }
}
  Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    final employees = await ApiService.getEmployees();
    final docCounts = await ApiService.getDocumentCounts();
    final companyDocs = await ApiService.getCompanyDocuments();

    setState(() {
      _employees = employees;
      _filteredEmployees = employees;
      _docCounts = docCounts;
      _companyDocCount = companyDocs.length;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}

  void _onSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _filteredEmployees = _employees;
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      final results = await ApiService.searchEmployees(query);
      final matchedIds = results.map((r) => r['emp_id'] as int).toSet();
      setState(() {
        _searchResults = results;
        _filteredEmployees =
            _employees.where((e) => matchedIds.contains(e.id)).toList();
        _isSearching = false;
      });
    } catch (e) {
      final q = query.toLowerCase();
      setState(() {
        _filteredEmployees = _employees.where((e) {
          return e.fullName.toLowerCase().contains(q) ||
              e.employeeId.toLowerCase().contains(q) ||
              (e.department?.toLowerCase().contains(q) ?? false) ||
              (e.jobPosition?.toLowerCase().contains(q) ?? false) ||
              (e.email?.toLowerCase().contains(q) ?? false);
        }).toList();
        _isSearching = false;
      });
    }
  }

  void _sortBy(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }

      _filteredEmployees.sort((a, b) {
        final aVal = _getFieldValue(a, column) ?? '';
        final bVal = _getFieldValue(b, column) ?? '';
        return _sortAscending
            ? aVal.toString().compareTo(bVal.toString())
            : bVal.toString().compareTo(aVal.toString());
      });
    });
  }

  String? _getFieldValue(Employee e, String field) {
    switch (field) {
      case 'employee_id':
        return e.employeeId;
      case 'full_name':
        return e.fullName;
      case 'department':
        return e.department;
      case 'job_position':
        return e.jobPosition;
      case 'nationality':
        return e.nationality;
      case 'email':
        return e.email;
      case 'phone':
        return e.phone;
      case 'contract_type':
        return e.contractType;
      case 'joining_date':
        return e.joiningDate?.toIso8601String();
      case 'start_date':
        return e.startDate?.toIso8601String();
      case 'wage_type':
        return e.wageType;
      default:
        return '';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _openDocumentPanel(Employee employee) {
    setState(() {
      _selectedEmployeeId = employee.id;
    });
  }

  void _closeDocumentPanel() {
    setState(() => _selectedEmployeeId = null);
  }

  void _toggleCompanyDocs() {
    setState(() => _showCompanyDocs = !_showCompanyDocs);
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final showEmployeeDocPanel =
      _selectedEmployeeId != null && screenWidth > 900;

  return Scaffold(
    backgroundColor: const Color(0xFFF0F2F8),
    body: Column(
      children: [
        _buildTopBar(),
        StatsBar(employees: _employees, docCounts: _docCounts),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: SearchBarWidget(
            onSearch: _onSearch,
            isSearching: _isSearching,
            searchResults: _searchResults,
            onResultTap: (empId) {
              final emp = _employees.firstWhere((e) => e.id == empId);
              _showEmployeeDetail(emp);
            },
          ),
        ),

        if (_showCompanyDocs)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              height: 320,
              child: CompanyDocumentsPanel(
                onClose: () {
                  setState(() => _showCompanyDocs = false);
                },
                onDocumentsChanged: () async {
                  await _loadCompanyDocCount();
                  await _loadData();
                },
              ),
            ),
          ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                Expanded(child: _buildDataTable()),
                if (showEmployeeDocPanel) ...[
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 360,
                    child: DocumentPanel(
                      employeeId: _selectedEmployeeId!,
                      employeeName: _employees
                          .firstWhere((e) => e.id == _selectedEmployeeId)
                          .fullName,
                      onClose: _closeDocumentPanel,
                      onDocumentsChanged: _loadData,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Employee Hub',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_employees.length} employees',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildTopButton(Icons.refresh_rounded, 'Refresh', _loadData),
          const SizedBox(width: 8),
          _buildTopButton(
  _showCompanyDocs
      ? Icons.folder_open_rounded
      : Icons.folder_copy_rounded,
  _showCompanyDocs
      ? 'Hide Company PDFs ($_companyDocCount)'
      : 'Company PDFs ($_companyDocCount)',
  _toggleCompanyDocs,
),
          const SizedBox(width: 8),
          _buildTopButton(
            Icons.person_add_rounded,
            'Add Employee',
            _showAddEmployeeDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredEmployees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : 'No employees found',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(const Color(0xFFF5F7FA)),
              headingRowHeight: 52,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 60,
              columnSpacing: 20,
              horizontalMargin: 20,
              showCheckboxColumn: false,
              sortColumnIndex:
                  _columns.indexWhere((c) => c.key == _sortColumn),
              sortAscending: _sortAscending,
              columns: _columns.map((col) {
                if (col.key == 'documents') {
                  return DataColumn(
                    label: Text(
                      col.label,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return DataColumn(
                  label: Text(
                    col.label,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  onSort: (_, __) => _sortBy(col.key),
                );
              }).toList(),
              rows: _filteredEmployees.map((emp) => _buildDataRow(emp)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(Employee emp) {
    final isSelected = _selectedEmployeeId == emp.id;
    final docCount = _docCounts[emp.id] ?? 0;

    return DataRow(
      selected: isSelected,
      color: WidgetStateProperty.resolveWith((states) {
        if (isSelected) return const Color(0xFF0D47A1).withOpacity(0.08);
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFF5F7FA);
        }
        return null;
      }),
      onSelectChanged: (_) => _showEmployeeDetail(emp),
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              emp.employeeId,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D47A1),
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _avatarColor(emp.fullName),
                child: Text(
                  emp.fullName.isNotEmpty ? emp.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  emp.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(_deptChip(emp.department ?? '—')),
        DataCell(Text(emp.jobPosition ?? '—', overflow: TextOverflow.ellipsis)),
        DataCell(Text(emp.nationality ?? '—')),
        DataCell(
          Text(
            emp.email ?? '—',
            style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(Text(emp.phone ?? '—', style: const TextStyle(fontSize: 13))),
        DataCell(Text(emp.contractType ?? '—')),
        DataCell(
          Text(_formatDate(emp.joiningDate), style: const TextStyle(fontSize: 13)),
        ),
        DataCell(
          Text(_formatDate(emp.startDate), style: const TextStyle(fontSize: 13)),
        ),
        DataCell(Text(emp.wageType ?? '—')),
        DataCell(
          InkWell(
            onTap: () => _openDocumentPanel(emp),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: docCount > 0
                    ? const Color(0xFF00897B).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    docCount > 0
                        ? Icons.folder_rounded
                        : Icons.upload_file_rounded,
                    size: 16,
                    color: docCount > 0
                        ? const Color(0xFF00897B)
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$docCount',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: docCount > 0
                          ? const Color(0xFF00897B)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _deptChip(String dept) {
    final colors = {
      'HO': (const Color(0xFF0D47A1), const Color(0xFFE3F2FD)),
      'KSA': (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
      'Beirut': (const Color(0xFFE65100), const Color(0xFFFFF3E0)),
    };

    final pair = colors[dept] ?? (Colors.grey.shade700, Colors.grey.shade100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pair.$2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        dept,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: pair.$1,
        ),
      ),
    );
  }

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF0D47A1),
      const Color(0xFF00897B),
      const Color(0xFFE65100),
      const Color(0xFF6A1B9A),
      const Color(0xFFC62828),
      const Color(0xFF283593),
      const Color(0xFF00695C),
      const Color(0xFF4E342E),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  void _showEmployeeDetail(Employee emp) {
    showDialog(
      context: context,
      builder: (_) => EmployeeDetailDialog(
        employee: emp,
        docCount: _docCounts[emp.id] ?? 0,
        onOpenDocs: () {
          Navigator.pop(context);
          _openDocumentPanel(emp);
        },
        onDataChanged: _loadData,
      ),
    );
  }

  void _showAddEmployeeDialog() {
    bool isArabic = false;

    final labels = {
      'en': {
        'title': 'Add New Employee',
        'personal': 'Personal Info',
        'employment': 'Employment',
        'dates': 'Dates',
        'id': 'Employee ID *',
        'name': 'Full Name *',
        'nationality': 'Nationality',
        'email': 'Email',
        'phone': 'Phone',
        'bank': 'Bank Account Nb',
        'dept': 'Department',
        'pos': 'Job Position',
        'contract': 'Contract Type',
        'wageType': 'Wage Type',
        'salary': 'Basic Salary',
        'allowances': 'Other Allowances',
        'joining': 'Joining Date',
        'start': 'Start Date',
        'end': 'End Date',
        'cancel': 'Cancel',
        'add': 'Add Employee',
        'required': 'Employee ID and Full Name are required',
        'success': 'Employee added!',
        'dateHint': 'YYYY-MM-DD',
      },
      'ar': {
        'title': 'إضافة موظف جديد',
        'personal': 'المعلومات الشخصية',
        'employment': 'معلومات التوظيف',
        'dates': 'التواريخ',
        'id': 'رقم الموظف *',
        'name': 'الاسم الكامل *',
        'nationality': 'الجنسية',
        'email': 'البريد الإلكتروني',
        'phone': 'رقم الهاتف',
        'bank': 'رقم الحساب البنكي',
        'dept': 'القسم',
        'pos': 'المسمى الوظيفي',
        'contract': 'نوع العقد',
        'wageType': 'نوع الراتب',
        'salary': 'الراتب الأساسي',
        'allowances': 'بدلات أخرى',
        'joining': 'تاريخ الالتحاق',
        'start': 'تاريخ البداية',
        'end': 'تاريخ الانتهاء',
        'cancel': 'إلغاء',
        'add': 'إضافة موظف',
        'required': 'رقم الموظف والاسم الكامل مطلوبان',
        'success': 'تمت إضافة الموظف!',
        'dateHint': 'YYYY-MM-DD',
      },
    };

    final ctrls = {
      for (var k in [
        'id',
        'name',
        'email',
        'phone',
        'dept',
        'pos',
        'nationality',
        'contract',
        'wageType',
        'salary',
        'allowances',
        'joining',
        'start',
        'end',
        'bank',
      ])
        k: TextEditingController()
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final l = isArabic ? labels['ar']! : labels['en']!;
          final dir = isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr;

          return Directionality(
            textDirection: dir,
            child: AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      l['title']!,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isArabic
                          ? const Color(0xFF0D47A1).withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () => setDialogState(() => isArabic = !isArabic),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          isArabic ? 'EN' : 'عربي',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isArabic
                                ? const Color(0xFF0D47A1)
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l['personal']!,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrls['id'],
                              textDirection: dir,
                              decoration:
                                  InputDecoration(labelText: l['id']),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: ctrls['name'],
                              textDirection: dir,
                              decoration:
                                  InputDecoration(labelText: l['name']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrls['nationality'],
                              textDirection: dir,
                              decoration: InputDecoration(
                                labelText: l['nationality'],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: ctrls['email'],
                              textDirection: ui.TextDirection.ltr,
                              decoration:
                                  InputDecoration(labelText: l['email']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrls['phone'],
                              textDirection: ui.TextDirection.ltr,
                              decoration:
                                  InputDecoration(labelText: l['phone']),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: ctrls['bank'],
                              textDirection: ui.TextDirection.ltr,
                              decoration:
                                  InputDecoration(labelText: l['bank']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l['employment']!,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrls['dept'],
                              textDirection: dir,
                              decoration:
                                  InputDecoration(labelText: l['dept']),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: ctrls['pos'],
                              textDirection: dir,
                              decoration:
                                  InputDecoration(labelText: l['pos']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrls['contract'],
                              textDirection: dir,
                              decoration: InputDecoration(
                                labelText: l['contract'],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: ctrls['wageType'],
                              textDirection: dir,
                              decoration: InputDecoration(
                                labelText: l['wageType'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrls['salary'],
                              textDirection: ui.TextDirection.ltr,
                              decoration:
                                  InputDecoration(labelText: l['salary']),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: ctrls['allowances'],
                              textDirection: ui.TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: l['allowances'],
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l['dates']!,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrls['joining'],
                              textDirection: ui.TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: l['joining'],
                                hintText: l['dateHint'],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: ctrls['start'],
                              textDirection: ui.TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: l['start'],
                                hintText: l['dateHint'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrls['end'],
                              textDirection: ui.TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: l['end'],
                                hintText: l['dateHint'],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l['cancel']!),
                ),
                FilledButton(
                  onPressed: () async {
                    if (ctrls['id']!.text.isEmpty || ctrls['name']!.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l['required']!)),
                      );
                      return;
                    }

                    try {
                      String? nullIfEmpty(String? v) =>
                          (v == null || v.trim().isEmpty) ? null : v.trim();

                      double? toDouble(String? v) =>
                          (v == null || v.trim().isEmpty)
                              ? null
                              : double.tryParse(v.trim());

                      await ApiService.addEmployee({
                        'employee_id': ctrls['id']!.text,
                        'full_name': ctrls['name']!.text,
                        'nationality': nullIfEmpty(ctrls['nationality']!.text),
                        'email': nullIfEmpty(ctrls['email']!.text),
                        'phone': nullIfEmpty(ctrls['phone']!.text),
                        'department': nullIfEmpty(ctrls['dept']!.text),
                        'job_position': nullIfEmpty(ctrls['pos']!.text),
                        'contract_type': nullIfEmpty(ctrls['contract']!.text),
                        'wage_type': nullIfEmpty(ctrls['wageType']!.text),
                        'basic_salary': toDouble(ctrls['salary']!.text),
                        'other_allowances': toDouble(ctrls['allowances']!.text),
                        'joining_date': nullIfEmpty(ctrls['joining']!.text),
                        'start_date': nullIfEmpty(ctrls['start']!.text),
                        'end_date': nullIfEmpty(ctrls['end']!.text),
                        'bank_account_nb': nullIfEmpty(ctrls['bank']!.text),
                      });

                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadData();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l['success']!),
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
                  },
                  child: Text(l['add']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ColumnConfig {
  final String key;
  final String label;
  final double width;

  _ColumnConfig(this.key, this.label, this.width);
}