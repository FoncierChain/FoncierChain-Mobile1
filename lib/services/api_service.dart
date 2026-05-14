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
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    ));
  }

  static Future<Map<String, dynamic>> registerOwner(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/register/owner/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<Map<String, dynamic>> registerOfficial(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/register/official/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<Map<String, dynamic>> registerHeir(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/register/heir/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<Map<String, dynamic>> submitKYC(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/kyc/submit/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  // --- Dashboard Statistics ---
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats/'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {}
    return {};
  }

  // --- Land workflow ---
  static Future<Map<String, dynamic>> signalFraud(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/signal-fraud/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<Map<String, dynamic>> verifySurvey(String landId, String action, {String? reason}) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/verify-survey/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'action': action, 'reason': reason}),
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

  static Future<Map<String, dynamic>> giveLocalAdvice(String landId, String comment, String action) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/local-advice/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'comment': comment, 'action': action}),
    ));
  }

  static Future<Map<String, dynamic>> notaryValidate(String landId, String signature) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/notary-validate/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature': signature}),
    ));
  }

  static Future<Map<String, dynamic>> ministryApprove(String landId, String signature) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/ministry-approve/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'signature': signature}),
    ));
  }

  static Future<Map<String, dynamic>> listSale(String landId) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/list-sale/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId}),
    ));
  }

  static Future<Map<String, dynamic>> executeSale(String landId, String buyerUid, String buyerSignature) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/execute-sale/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'land_id': landId, 'buyer_uid': buyerUid, 'buyer_signature': buyerSignature}),
    ));
  }

  static Future<Map<String, dynamic>> heritageSetup(String landId, String heirUid, String heirSignature, String mayorSignature) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/heritage-setup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'land_id': landId,
        'heir_uid': heirUid,
        'heir_signature': heirSignature,
        'mayor_signature': mayorSignature,
      }),
    ));
  }

  static Future<Map<String, dynamic>> signalFraud(Map<String, dynamic> data) async {
    return _handleResponse(http.post(
      Uri.parse('$baseUrl/land/signal-fraud/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  static Future<dynamic> citizenVerify(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/citizen/verify/?land_id=$query'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Erreur de connexion au registre citoyen'};
    }
  }
}
