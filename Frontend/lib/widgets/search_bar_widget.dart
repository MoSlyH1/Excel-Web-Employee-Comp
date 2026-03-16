import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final bool isSearching;
  final List<Map<String, dynamic>> searchResults;
  final Function(int) onResultTap;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.isSearching,
    required this.searchResults,
    required this.onResultTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _showResults = _focusNode.hasFocus && _controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(value);
    });
    setState(() => _showResults = value.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            style: GoogleFonts.dmSans(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search employees by name, ID, department, position, or document name...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: widget.isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.search_rounded, color: Colors.grey.shade500),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 20),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.grey.shade500, size: 20),
                      onPressed: () {
                        _controller.clear();
                        widget.onSearch('');
                        setState(() => _showResults = false);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // Search results dropdown
        if (_showResults && widget.searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: widget.searchResults.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (_, index) {
                  final result = widget.searchResults[index];
                  final isDocMatch =
                      (result['match_source'] as String?)?.startsWith('document:') ?? false;

                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          isDocMatch ? const Color(0xFF00897B).withOpacity(0.1) : const Color(0xFF0D47A1).withOpacity(0.1),
                      child: Icon(
                        isDocMatch ? Icons.description_rounded : Icons.person_rounded,
                        size: 18,
                        color: isDocMatch ? const Color(0xFF00897B) : const Color(0xFF0D47A1),
                      ),
                    ),
                    title: Text(
                      result['full_name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      isDocMatch
                          ? result['match_source'] ?? ''
                          : '${result['department'] ?? ''} · ${result['job_position'] ?? ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      result['employee_id_num'] ?? '',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    onTap: () {
                      widget.onResultTap(result['emp_id'] as int);
                      setState(() => _showResults = false);
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}