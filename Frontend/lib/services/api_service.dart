import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/employee.dart';




class ApiService {
  static const String baseUrl = '/api';






  // ─── EMPLOYEES ───────────────────────────────────────────

  static Future<List<Employee>> getEmployees() async {
    final response = await http.get(Uri.parse('$baseUrl/employees'));
    if (response.statusCode != 200) throw Exception('Failed to load employees');
    final List data = json.decode(response.body);
    return data.map((j) => Employee.fromJson(j)).toList();
  }

  static Future<Employee> getEmployee(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/employees/$id'));
    if (response.statusCode != 200) throw Exception('Employee not found');
    return Employee.fromJson(json.decode(response.body));
  }

  static Future<Employee> addEmployee(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employees'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) throw Exception('Failed to add employee');
    return Employee.fromJson(json.decode(response.body));
  }

  static Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/employees/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) throw Exception('Failed to update');
  }

  static Future<void> deleteEmployee(int id) async {
    await http.delete(Uri.parse('$baseUrl/employees/$id'));
  }

  // ─── SEARCH ──────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> searchEmployees(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
    );
    if (response.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  // ─── DOCUMENTS ───────────────────────────────────────────

  static Future<List<EmployeeDocument>> getDocuments(int employeeId) async {
    final response = await http.get(Uri.parse('$baseUrl/employees/$employeeId/documents'));
    if (response.statusCode != 200) return [];
    final List data = json.decode(response.body);
    return data.map((j) => EmployeeDocument.fromJson(j)).toList();
  }

  static Future<Map<int, int>> getDocumentCounts() async {
    final response = await http.get(Uri.parse('$baseUrl/document-counts'));
    if (response.statusCode != 200) return {};
    final Map<String, dynamic> data = json.decode(response.body);
    return data.map((k, v) => MapEntry(int.parse(k), v as int));
  }


  // ─── R3 FORM — Save R3 data to employee record ──────────

static Future<Employee> saveR3Data(int employeeId, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse('$baseUrl/employees/$employeeId'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to save R3 data: ${response.body}');
  }

  return Employee.fromJson(json.decode(response.body));
}


  static Future<Map<String, dynamic>> getCompanyInfo() async {
  final response = await http.get(Uri.parse('$baseUrl/company'));
  if (response.statusCode != 200) return {};
  final data = json.decode(response.body);
  if (data is Map<String, dynamic>) return data;
  return {};
}
  static Future<Employee> saveE3lamData(
  int employeeId,
  Map<String, dynamic> data,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/employees/$employeeId'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to save E3lam data: ${response.body}');
  }

  return Employee.fromJson(json.decode(response.body));
}
static Future<void> saveCompanyInfo(Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse('$baseUrl/company'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to save: ${response.body}');
  }
}

static Future<List<Map<String, dynamic>>> getCompanyDocuments() async {
  final response = await http.get(Uri.parse('$baseUrl/company/documents'));
  if (response.statusCode != 200) return [];
  return List<Map<String, dynamic>>.from(json.decode(response.body));
}

static Future<Map<String, dynamic>> uploadCompanyDocument({
  required String fileName,
  required Uint8List fileBytes,
  required String mimeType,
}) async {
  final uri = Uri.parse('$baseUrl/company/upload');
  final request = http.MultipartRequest('POST', uri);

  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    ),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode != 201) {
    throw Exception('Company document upload failed: ${response.body}');
  }

  return Map<String, dynamic>.from(json.decode(response.body));
}

static String getCompanyDocumentDownloadUrl(int docId) {
  return '$baseUrl/company/documents/$docId/download';
}

static Future<void> deleteCompanyDocument(int docId) async {
  final response =
      await http.delete(Uri.parse('$baseUrl/company/documents/$docId'));
  if (response.statusCode != 200) {
    throw Exception('Failed to delete company document');
  }
}


  static Future<List<EmployeeDocument>> uploadDocuments({
    required int employeeId,
    required List<String> fileNames,
    required List<Uint8List> fileBytes,
    required List<String> mimeTypes,
  }) async {
    final uri = Uri.parse('$baseUrl/employees/$employeeId/upload');
    final request = http.MultipartRequest('POST', uri);
    for (int i = 0; i < fileNames.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
        'files', fileBytes[i],
        filename: fileNames[i],
        contentType: MediaType.parse(mimeTypes[i]),
      ));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 201) throw Exception('Upload failed');
    final List data = json.decode(response.body);
    return data.map((j) => EmployeeDocument.fromJson(j)).toList();
  }

  static String getDownloadUrl(int docId) {
    return '$baseUrl/documents/$docId/download';
  }

  static Future<void> deleteDocument(int docId) async {
    await http.delete(Uri.parse('$baseUrl/documents/$docId'));
  }

  // ─── R4 FORM — Save R4 data to employee record ──────────

  static Future<Employee> saveR4Data(int employeeId, Map<String, dynamic> data) async {
    // Send all fields including nulls — backend handles type conversion
    final response = await http.put(
      Uri.parse('$baseUrl/employees/$employeeId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception('Failed to save R4 data: $body');
    }
    return Employee.fromJson(json.decode(response.body));
  }
}
