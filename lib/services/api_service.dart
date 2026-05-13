import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String baseUrl = '/api/v1'; // Use relative for web if served on same port
  
  static void setEnvironment(bool isPro) {
    if (isPro) {
      baseUrl = 'https://api-pro.foncierchain.cg/api/v1'; 
    } else {
      baseUrl = '/api/v1';
    }
  }

  static Future<Map<String, dynamic>> _handleResponse(Future<http.Response> request) async {
    try {
      final response = await request;
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'FAILED',
        'message': 'Problème de connexion internet ou serveur injoignable. Le système FoncierChain nécessite une connexion active.',
        'error': e.toString(),
        'is_offline': true
      };
    }
  }

  // --- Auth & KYC ---
  static Future<Map<String, dynamic>> login(String username, String password) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    ));
  }

  static Future<Map<String, dynamic>> registerOwner(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/register/owner'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<Map<String, dynamic>> submitKYC(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/kyc/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  // --- Dashboard Statistics ---
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {}
    return {};
  }

  // --- Land workflow ---
  static Future<Map<String, dynamic>> signalFraud(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/signal'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<Map<String, dynamic>> approveDraft(String parcelId, String action) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/approve-draft'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'parcel_id': parcelId, 'action': action}),
    ));
  }

  // --- Public Registry ---
  static Future<Map<String, dynamic>> getPublicRegistry() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/registry/public'));
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
      final response = await http.get(Uri.parse('$baseUrl/map'));
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
      Uri.parse('$baseUrl/land/draft'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<Map<String, dynamic>> validateLand(String landId, String signature) async {
    return _handleResponse(http.patch(
      Uri.parse('$baseUrl/land/validate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature_v3': signature}),
    ));
  }

  static Future<Map<String, dynamic>> finalizeLand(String landId, String signature) async {
    return _handleResponse(http.patch(
      Uri.parse('$baseUrl/land/finalize'),
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

  // --- Reports ---
  static Future<Map<String, dynamic>> getReports() async {
    return _handleResponse(http.get(Uri.parse('$baseUrl/reports')));
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
  static Future<Map<String, dynamic>> reviewKYC(String username, String action, {String? reason}) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/kyc/review'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'action': action, 'reason': reason}),
    ));
  }

  static Future<Map<String, dynamic>> verifyKYC(String entityId, String idNumber) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/kyc/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_number': idNumber}),
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

  // --- IBIVI / FANCIERCHAIN 2026 WORKFLOW ---

  static Future<Map<String, dynamic>> openEscrow(String landId, double amount) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/escrow/open'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'amount': amount}),
    ));
  }

  static Future<Map<String, dynamic>> submitOpposition(String landId, String reason, String proofHash) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/oppose'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'reason': reason, 'proof_hash': proofHash}),
    ));
  }

  static Future<Map<String, dynamic>> getPerformanceAudit() async {
    return _handleResponse(http.get(Uri.parse('$baseUrl/land/performance-audit')));
  }

  static Future<Map<String, dynamic>> giveLocalAdvice(String landId, String comment, String action) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/local-advice'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'comment': comment, 'action': action}),
    ));
  }

  static Future<Map<String, dynamic>> notaryValidate(String landId, String signature) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/notary-validate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature': signature}),
    ));
  }

  static Future<Map<String, dynamic>> ministryApprove(String landId, String signature) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/ministry-approve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature': signature}),
    ));
  }

  static Future<Map<String, dynamic>> notifyHeritage(String landId, String deathCertId) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/heritage-notify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'death_cert_id': deathCertId}),
    ));
  }

  static Future<Map<String, dynamic>> fragmentHeritage(String landId, List<Map<String, dynamic>> heirs) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/heritage-fragment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'heirs': heirs}),
    ));
  }

  static Future<dynamic> citizenVerify(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/citizen/verify?land_id=$query'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Erreur de connexion au registre citoyen'};
    }
  }
}
