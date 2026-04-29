import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Land Registry Endpoints
  
  /// Register a new property record on the blockchain.
  Future<Map<String, dynamic>> registerLand({
    required String id,
    required String owner,
    required String location,
    required double area,
    required double price,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}land/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'owner': owner,
        'location': location,
        'area': area,
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register land: ${response.statusCode} - ${response.body}');
    }
  }

  /// Retrieves the full chain of custody for a specific plot.
  Future<Map<String, dynamic>> getLandHistory(String landId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}land/$landId/history/'),
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'auction_id': auctionId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to finalize auction: ${response.statusCode} - ${response.body}');
    }
  }
}
