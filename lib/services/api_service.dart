import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String baseUrl = 'https://foncierchain-backend1-1.onrender.com/api/v1';
  
  static void setEnvironment(bool isPro) {
    if (isPro) {
      baseUrl = 'https://api-pro.foncierchain.cg/api/v1'; // Simulated Pro URL
    } else {
      baseUrl = 'https://foncierchain-backend1-1.onrender.com/api/v1';
    }
  }

  static Future<Map<String, dynamic>> _handleResponse(Future<http.Response> request) async {
    try {
      final response = await request;
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'FAILED',
        'message': 'Problème de connexion internet ou serveur injoignable. Le système FoncierChain nécessite une connexion active pour les écritures sur la blockchain.',
        'error': e.toString(),
        'is_offline': true
      };
    }
  }

  // --- Auth ---
  static Future<Map<String, dynamic>> login(String username, String password) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/auth/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    ));
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
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/draft/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<Map<String, dynamic>> validateLand(String landId, String signature) async {
    return _handleResponse(http.patch(
      Uri.parse('$baseUrl/land/validate/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature_v3': signature}),
    ));
  }

  static Future<Map<String, dynamic>> finalizeLand(String landId, String signature) async {
    return _handleResponse(http.patch(
      Uri.parse('$baseUrl/land/finalize/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature_v1': signature}),
    ));
  }

  static Future<Map<String, dynamic>> getLandHistory(String landId) async {
    return _handleResponse(http.get(Uri.parse('$baseUrl/land/$landId/history/')));
  }

  // --- Geo Data ---
  static Future<Map<String, dynamic>> getCongoGeoData() async {
    return _handleResponse(http.get(Uri.parse('$baseUrl/geo/congo')));
  }

  // --- Support ---
  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/support/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    ));
  }

  static Future<Map<String, dynamic>> createTicket(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/support/tickets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  // --- Security & KYC ---
  static Future<Map<String, dynamic>> verifyKYC(String entityId, String idNumber) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/kyc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'entity_id': entityId, 'id_number': idNumber}),
    ));
  }

  static Future<Map<String, dynamic>> mutateLand(String landId, String newOwnerId) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/mutate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'new_owner_id': newOwnerId}),
    ));
  }

  static Future<Map<String, dynamic>> reportDispute(String landId, String reason, String reporterId) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/dispute'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'land_id': landId,
        'reason': reason,
        'reporter_id': reporterId,
      }),
    ));
  }

  static Future<List<dynamic>> citizenVerify(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/citizen/verify?land_id=$query'));
    return jsonDecode(response.body);
  }
}
