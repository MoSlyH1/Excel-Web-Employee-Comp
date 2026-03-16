import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

class DocumentPanel extends StatefulWidget {
  final int employeeId;
  final String employeeName;
  final VoidCallback onClose;
  final VoidCallback onDocumentsChanged;

  const DocumentPanel({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.onClose,
    required this.onDocumentsChanged,
  });

  @override
  State<DocumentPanel> createState() => _DocumentPanelState();
}

class _DocumentPanelState extends State<DocumentPanel> {
  List<EmployeeDocument> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void didUpdateWidget(DocumentPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employeeId != widget.employeeId) _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final docs = await ApiService.getDocuments(widget.employeeId);
      setState(() { _documents = docs; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any, withData: true);
      if (result == null || result.files.isEmpty) return;

      setState(() => _isUploading = true);

      final names = <String>[];
      final bytes = <Uint8List>[];
      final mimes = <String>[];
      for (final f in result.files) {
        if (f.bytes == null) continue;
        names.add(f.name);
        bytes.add(f.bytes!);
        mimes.add(_getMimeType(f.name));
      }

      await ApiService.uploadDocuments(
        employeeId: widget.employeeId,
        fileNames: names,
        fileBytes: bytes,
        mimeTypes: mimes,
      );

      setState(() => _isUploading = false);
      _loadDocuments();
      widget.onDocumentsChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${names.length} file(s) uploaded!'), backgroundColor: const Color(0xFF00897B)),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _downloadFile(EmployeeDocument doc) async {
  try {
    final url = ApiService.getDownloadUrl(doc.id!);
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get download link: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

  Future<void> _deleteFile(EmployeeDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${doc.fileName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService.deleteDocument(doc.id!);
      _loadDocuments();
      widget.onDocumentsChanged();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  String _getMimeType(String name) {
    final ext = name.split('.').last.toLowerCase();
    const m = {'pdf': 'application/pdf', 'doc': 'application/msword', 'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'xls': 'application/vnd.ms-excel', 'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'png': 'image/png', 'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'txt': 'text/plain'};
    return m[ext] ?? 'application/octet-stream';
  }

  IconData _icon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) { case 'pdf': return Icons.picture_as_pdf_rounded; case 'doc': case 'docx': return Icons.description_rounded; case 'xls': case 'xlsx': return Icons.table_chart_rounded; case 'png': case 'jpg': case 'jpeg': return Icons.image_rounded; default: return Icons.insert_drive_file_rounded; }
  }

  Color _fileColor(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) { case 'pdf': return Colors.red.shade700; case 'doc': case 'docx': return Colors.blue.shade700; case 'xls': case 'xlsx': return Colors.green.shade700; case 'png': case 'jpg': case 'jpeg': return Colors.purple.shade700; default: return Colors.grey.shade700; }
  }

  String _fmtSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF00897B).withOpacity(0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(children: [
            const Icon(Icons.folder_open_rounded, color: Color(0xFF00897B), size: 22),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Documents', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(widget.employeeName, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ])),
            IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: widget.onClose,
              style: IconButton.styleFrom(backgroundColor: Colors.grey.shade200, padding: const EdgeInsets.all(6))),
          ]),
        ),

        // Upload
        Padding(
          padding: const EdgeInsets.all(16),
          child: _isUploading
              ? const Center(child: CircularProgressIndicator())
              : InkWell(
                  onTap: _uploadFile, borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00897B)), borderRadius: BorderRadius.circular(12), color: const Color(0xFF00897B).withOpacity(0.04)),
                    child: Column(children: [
                      Icon(Icons.cloud_upload_rounded, size: 32, color: const Color(0xFF00897B).withOpacity(0.7)),
                      const SizedBox(height: 8),
                      Text('Click to upload files', style: TextStyle(fontWeight: FontWeight.w600, color: const Color(0xFF00897B).withOpacity(0.8))),
                      const SizedBox(height: 4),
                      Text('PDF, Word, Excel, Images, etc.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                  ),
                ),
        ),

        // List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _documents.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.folder_off_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No documents yet', style: TextStyle(color: Colors.grey.shade500)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _documents.length,
                      itemBuilder: (_, i) {
                        final doc = _documents[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                          child: ListTile(
                            dense: true,
                            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _fileColor(doc.fileName).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Icon(_icon(doc.fileName), color: _fileColor(doc.fileName), size: 20)),
                            title: Text(doc.fileName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                            subtitle: Text('${_fmtSize(doc.fileSize)}${doc.uploadedAt != null ? ' · ${DateFormat('dd MMM yyyy').format(doc.uploadedAt!)}' : ''}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(icon: const Icon(Icons.download_rounded, size: 18), onPressed: () => _downloadFile(doc), tooltip: 'Download'),
                              IconButton(icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade400), onPressed: () => _deleteFile(doc), tooltip: 'Delete'),
                            ]),
                          ),
                        );
                      }),
        ),
      ]),
    );
  }
}