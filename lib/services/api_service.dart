import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({required this.baseUrl});

  /// Sets the authentication token for subsequent requests.
  void setToken(String? token) {
    _token = token;
  }

  /// Helper to get common headers, including authorization if token is set.
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Token $_token';
    }
    return headers;
  }

  // 0. Authentication Endpoints

  /// Creates a new account and returns a permanent API token.
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return data;
    } else {
      throw Exception('Registration failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Retrieves a token for an existing user.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return data;
    } else {
      throw Exception('Login failed: ${response.statusCode} - ${response.body}');
    }
  }

  // 1. Sequential Registration Workflow

  /// Step 1: Initiate Draft (Actor: Géomètre Agréé)
  Future<Map<String, dynamic>> initiateDraft({
    required String id,
    required String owner,
    required String city,
    required String neighborhood,
    required String cadastralId,
    required int area,
    required int price,
    required String signatureV2,
    required String documentHash,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}land/draft/'),
      headers: _getHeaders(),
      body: jsonEncode({
        'id': id,
        'owner': owner,
        'city': city,
        'neighborhood': neighborhood,
        'cadastralId': cadastralId,
        'area': area,
        'price': price,
        'signatureV2': signatureV2,
        'documentHash': documentHash,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initiate draft: ${response.statusCode} - ${response.body}');
    }
  }

  /// Step 2: Community Validation (Actor: Représentant Communautaire)
  Future<Map<String, dynamic>> validateCommunity({
    required String landId,
    required String signatureV3,
  }) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}land/validate/'),
      headers: _getHeaders(),
      body: jsonEncode({
        'land_id': landId,
        'signature_v3': signatureV3,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed community validation: ${response.statusCode} - ${response.body}');
    }
  }

  /// Step 3: Finalization (Actor: Agent Foncier de l'Etat)
  Future<Map<String, dynamic>> finalizeLand({
    required String landId,
    required String signatureV1,
  }) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}land/finalize/'),
      headers: _getHeaders(),
      body: jsonEncode({
        'land_id': landId,
        'signature_v1': signatureV1,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to finalize land: ${response.statusCode} - ${response.body}');
    }
  }

  /// Retrieves the full chain of custody for a specific plot.
  Future<Map<String, dynamic>> getLandHistory(String landId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}land/$landId/history/'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get land history: ${response.statusCode} - ${response.body}');
    }
  }

  // Sovereign Identity (SSI) Endpoints

  /// Initiates an X.509 certificate validation against the Fabric CA.
  Future<Map<String, dynamic>> verifyIdentity(String identityToken) async {
    final response = await http.post(
      Uri.parse('${baseUrl}identity/verify/'),
      headers: _getHeaders(),
      body: jsonEncode({'identity_token': identityToken}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Identity verification failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Returns the current verification tier of the logged-in user.
  Future<Map<String, dynamic>> getIdentityStatus() async {
    final response = await http.get(
      Uri.parse('${baseUrl}identity/status/'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get identity status: ${response.statusCode} - ${response.body}');
    }
  }

  // Real-time Auctions Endpoints

  /// Places a competitive bid on a land auction.
  Future<Map<String, dynamic>> placeBid({
    required String auctionId,
    required String bidderId,
    required int amount,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auctions/bid/'),
      headers: _getHeaders(),
      body: jsonEncode({
        'auction_id': auctionId,
        'bidder_id': bidderId,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to place bid: ${response.statusCode} - ${response.body}');
    }
  }

  /// Closes the auction and transfers ownership to the highest bidder on the blockchain.
  Future<Map<String, dynamic>> finalizeAuction(String auctionId) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}auctions/finalize/'),
      headers: _getHeaders(),
      body: jsonEncode({'auction_id': auctionId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to finalize auction: ${response.statusCode} - ${response.body}');
    }
  }
}
