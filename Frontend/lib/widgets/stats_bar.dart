import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/employee.dart';

class StatsBar extends StatelessWidget {
  final List<Employee> employees;
  final Map<int, int> docCounts;

  const StatsBar({super.key, required this.employees, required this.docCounts});

  @override
  Widget build(BuildContext context) {
    final totalDocs = docCounts.values.fold(0, (a, b) => a + b);
    final departments = employees.map((e) => e.department).where((d) => d != null).toSet();
    final withDocs = docCounts.keys.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: const Color(0xFFF0F2F8),
      child: Row(
        children: [
          _stat(Icons.people_rounded, '${employees.length}', 'Employees', const Color(0xFF0D47A1)),
          const SizedBox(width: 24),
          _stat(Icons.business_rounded, '${departments.length}', 'Departments', const Color(0xFF6A1B9A)),
          const SizedBox(width: 24),
          _stat(Icons.description_rounded, '$totalDocs', 'Documents', const Color(0xFF00897B)),
          const SizedBox(width: 24),
          _stat(Icons.check_circle_rounded, '$withDocs', 'With Docs', const Color(0xFFE65100)),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700, fontSize: 18, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}