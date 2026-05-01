import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://foncierchain-backend1-1.onrender.com/api/v1';

  // --- Auth ---
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // --- Dashboard Statistics ---
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats/'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
    return {};
  }

  // --- Public Registry ---
  static Future<Map<String, dynamic>> getPublicRegistry() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/registry/public/'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching registry: $e');
    }
    return {};
  }

  // --- Land Map Data ---
  static Future<List<dynamic>> getMapData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/map/'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching map data: $e');
    }
    return [];
  }

  // --- land Workflow ---
  static Future<Map<String, dynamic>> createDraft(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/land/draft/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> validateLand(String landId, String signature) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/land/validate/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature_v3': signature}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> finalizeLand(String landId, String signature) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/land/finalize/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature_v1': signature}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getLandHistory(String landId) async {
    final response = await http.get(Uri.parse('$baseUrl/land/$landId/history/'));
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> citizenVerify(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/citizen/verify?land_id=$query'));
    return jsonDecode(response.body);
  }
}
