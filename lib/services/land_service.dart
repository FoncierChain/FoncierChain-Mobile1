import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:latlong2/latlong.dart';
import 'api_service.dart';

import 'package:google_generative_ai/google_generative_ai.dart';

enum MapLayerType { street, satellite, terrain }

class ProtectedZone {
  final String name;
  final List<LatLng> polygon;
  final String reason;

  ProtectedZone({required this.name, required this.polygon, required this.reason});
}

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String? photoURL;
  final bool isKYCVerified;
  final Map<String, dynamic>? kycData;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoURL,
    this.isKYCVerified = false,
    this.kycData,
  });
}

class Parcel {
  final String id;
  final String ownerName;
  final String ownerId;
  final String city;
  final String neighborhood;
  final String cadastralId;
  final double area;
  final double price;
  final String usage;
  final String address;
  final String status;
  final String landType; // New field
  final double? escrowAmount;
  final String? escrowOpenedAt;
  final String? oppositionReason;
  final String? oppositionProof;
  final String? signatureV1;
  final String? signatureV2;
  final String? signatureV3;
  final String? notarySignature;
  final String? ministrySignature;
  final String? localAdvice;
  final String? documentHash;
  final String? txId;
  final DateTime lastUpdate;

  Parcel({
    required this.id,
    required this.ownerName,
    required this.ownerId,
    required this.city,
    required this.neighborhood,
    required this.cadastralId,
    required this.area,
    required this.price,
    required this.usage,
    required this.address,
    required this.status,
    required this.landType,
    this.escrowAmount,
    this.escrowOpenedAt,
    this.oppositionReason,
    this.oppositionProof,
    this.signatureV1,
    this.signatureV2,
    this.signatureV3,
    this.notarySignature,
    this.ministrySignature,
    this.localAdvice,
    this.documentHash,
    this.txId,
    required this.lastUpdate,
  });

  factory Parcel.fromMap(Map<String, dynamic> data) {
    return Parcel(
      id: data['parcelId'] ?? data['id']?.toString() ?? '',
      ownerName: data['owner'] ?? data['currentOwner'] ?? data['ownerName'] ?? '',
      ownerId: data['ownerId'] ?? 'UID-TEMP',
      city: data['city'] ?? 'Brazzaville',
      neighborhood: data['neighborhood'] ?? '',
      cadastralId: data['cadastralId'] ?? "CAD-${data['parcelId'] ?? data['id']}",
      area: (data['area'] ?? data['surface'] ?? 0).toDouble(),
      price: (data['price'] ?? 0).toDouble(),
      usage: data['usage'] ?? data['usage_type'] ?? '',
      address: data['address'] ?? '',
      status: data['status'] ?? 'DRAFT',
      landType: data['land_type'] ?? 'Cadastre',
      escrowAmount: (data['escrow_amount'] ?? 0).toDouble(),
      escrowOpenedAt: data['escrow_opened_at'],
      oppositionReason: data['opposition_reason'],
      oppositionProof: data['opposition_proof'],
      signatureV1: data['signature_v1'],
      signatureV2: data['signature_v2'],
      signatureV3: data['signature_v3'],
      notarySignature: data['notary_signature'],
      ministrySignature: data['ministry_signature'],
      localAdvice: data['local_advice'],
      documentHash: data['hash'] ?? data['documentHash'],
      txId: data['txId'] ?? data['hash'],
      lastUpdate: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : (data['timestamp'] != null ? DateTime.parse(data['timestamp']) : DateTime.now()),
    );
  }
}

class TransactionHistory {
  final String previousOwner;
  final String newOwner;
  final DateTime date;
  final String type;
  final String documentHash;

  TransactionHistory({
    required this.previousOwner,
    required this.newOwner,
    required this.date,
    required this.type,
    required this.documentHash,
  });

  factory TransactionHistory.fromMap(Map<String, dynamic> data) {
    return TransactionHistory(
      previousOwner: data['previousOwner'] ?? '',
      newOwner: data['newOwner'] ?? '',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      type: data['type'] ?? 'Mutation',
      documentHash: data['documentHash'] ?? '',
    );
  }
}

enum OperationType {
  CREATE,
  UPDATE,
  DELETE,
  LIST,
  GET,
  WRITE,
}

class LandService with ChangeNotifier {
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  Map<String, List<String>> _congoGeoData = {
    "Brazzaville": ["Makélékélé", "Bacongo", "Poto-Poto", "Moungali", "Ouenzé", "Talangaï", "Mfilou", "Madibou", "Djiri"],
    "Pointe-Noire": ["Lumumba", "Mvoumvou", "Tié-Tié", "Loandjili", "Mongo-Mpoucou", "Ngoyo"],
  };
  Map<String, List<String>> get congoGeoData => _congoGeoData;

  MapLayerType _currentMapType = MapLayerType.street;
  MapLayerType get currentMapType => _currentMapType;

  void setMapType(MapLayerType type) {
    _currentMapType = type;
    notifyListeners();
  }

  final List<ProtectedZone> _protectedZones = [
    ProtectedZone(
      name: "Palais du Peuple (Zone État)",
      polygon: [
        LatLng(-4.2710, 15.2810),
        LatLng(-4.2730, 15.2810),
        LatLng(-4.2730, 15.2830),
        LatLng(-4.2710, 15.2830),
      ],
      reason: "Siège des institutions de la République. Inaliénable.",
    ),
    ProtectedZone(
      name: "Parc National d'Odzala (Zone Verte)",
      polygon: [
        LatLng(0.8000, 14.8000),
        LatLng(1.2000, 14.8000),
        LatLng(1.2000, 15.2000),
        LatLng(0.8000, 15.2000),
      ],
      reason: "Patrimoine naturel protégé. Aucune exploitation foncière autorisée.",
    ),
  ];
  List<ProtectedZone> get protectedZones => _protectedZones;

  LatLng getCenterForLocation(String city, String neighborhood) {
    // Basic approximate coordinates
    if (city == "Brazzaville") {
      if (neighborhood == "Madibou") return LatLng(-4.3168, 15.1914);
      if (neighborhood == "Talangaï") return LatLng(-4.2341, 15.3045);
      return LatLng(-4.2634, 15.2832);
    }
    if (city == "Pointe-Noire") {
      return LatLng(-4.7787, 11.8594);
    }
    return LatLng(-4.2634, 15.2832);
  }

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  Future<void> fetchGeoData() async {
    try {
      final res = await ApiService.getCongoGeoData();
      _isOffline = res['is_offline'] == true;
      if (res['cities'] != null) {
        Map<String, List<String>> newData = {};
        for (var cityGroup in res['cities']) {
          newData[cityGroup['name'].toString()] = List<String>.from(cityGroup['neighborhoods']);
        }
        _congoGeoData = newData;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("GeoData error: $e");
    }
  }

  Future<void> verifyKYC(String idNumber, {Map<String, dynamic>? extractedData}) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.verifyKYC(_currentUser!.uid, idNumber);
      _isOffline = res['is_offline'] == true;
      if (res['status'] == 'SUCCESS') {
        _currentUser = AppUser(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          role: _currentUser!.role,
          isKYCVerified: true,
          kycData: extractedData,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> analyzeKYCWithGemini(Uint8List recto, Uint8List verso) async {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      return {'error': "Clé API Gemini non configurée dans l'environnement."};
    }

    final model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
    );

    final prompt = """
      Analysez ces deux images (recto et verso) d'une pièce d'identité de la République du Congo.
      Extrayez les informations suivantes au format JSON :
      - nom: String
      - prenom: String
      - id_number: String
      - date_expiration: String (Format YYYY-MM-DD)
      - est_expire: Boolean (Vérifiez si la date d'expiration est passée par rapport à aujourd'hui: ${DateTime.now().toIso8601String()})
      
      Si la pièce est expirée, 'est_expire' doit être true.
      Répondez UNIQUEMENT avec le JSON.
    """;

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', recto),
        DataPart('image/jpeg', verso),
      ])
    ];

    try {
      final response = await model.generateContent(content);
      final text = response.text;
      if (text == null) throw Exception("Pas de réponse de Gemini");
      
      // Clean potential markdown code blocks
      final cleanedText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleanedText);
    } catch (e) {
      debugPrint("Gemini KYC Error: $e");
      return {'error': "Erreur lors de l'analyse avec Gemini: $e"};
    }
  }
  String? _pendingSearchQuery;
  String? get pendingSearchQuery => _pendingSearchQuery;

  String? _simulatedRole;
  String? get simulatedRole => _simulatedRole;

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setSimulatedRole(String? role) {
    _simulatedRole = role;
    notifyListeners();
  }

  String _userRole = 'CITIZEN';
  String get userRole => _simulatedRole ?? _userRole;

  final List<Map<String, dynamic>> _chatHistory = [
    {"text": "Bonjour ! Je suis l'assistant FoncierChain. Comment puis-je vous aider ?", "isMe": false},
  ];
  List<Map<String, dynamic>> get chatHistory => _chatHistory;

  void addChatMessage(String text, bool isMe) {
    _chatHistory.add({"text": text, "isMe": isMe});
    notifyListeners();
  }

  Future<void> sendChatMessage(String message) async {
    addChatMessage(message, true);
    try {
      final res = await ApiService.sendChatMessage(message);
      String botReply = res['reply'] ?? res['message'] ?? "Je ne suis pas sûr de comprendre. Pouvez-vous reformuler ?";
      addChatMessage(botReply, false);
    } catch (e) {
      addChatMessage("Erreur de connexion au chatbot.", false);
    }
  }

  void setTabIndex(int index, {String? searchQuery}) {
    _currentTabIndex = index;
    if (searchQuery != null) {
      _pendingSearchQuery = searchQuery;
    }
    notifyListeners();
  }

  void clearPendingSearch() {
    _pendingSearchQuery = null;
  }

  final Map<String, int> _statusColors = {
    'DRAFT': 0xFFA9A9A9,
    'ESCROW_OPENED': 0xFF00BFFF,
    'PENDING_OPPOSITION': 0xFFFFD700,
    'FROZEN_OPPOSITION': 0xFFB22222,
    'LOCAL_ADVICE_GIVEN': 0xFF6495ED,
    'COMMUNITY_VALIDATED': 0xFFDA70D6,
    'NOTARY_VALIDATED': 0xFF4169E1,
    'FINALIZED': 0xFF228B22,
    'EN_LITIGE': 0xFFFF4500,
    'BLOCKED_FOR_HERITAGE': 0xFF8B0000,
  };

  final Map<String, int> _landTypeColors = {
    'Cadastre': 0xFF009543,
    'Coutumier': 0xFFFBDE4A,
    'Réserve État': 0xFFDC241F,
    'Agricole': 0xFF8B4513,
    'Minière': 0xFF708090,
    'Forestière': 0xFF006400,
    'En Vente': 0xFF00BFFF,
  };

  int getLandColor(String? type, String? status) {
    if (_statusColors.containsKey(status)) {
      return _statusColors[status]!;
    }
    return _landTypeColors[type] ?? _landTypeColors['Cadastre']!;
  }

  // --- IBIVI / FANCIERCHAIN 2026 WORKFLOW METHODS ---

  Future<void> openEscrow(String landId, double amount) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.openEscrow(landId, amount);
      if (res['status'] == 'FAILED') throw Exception(res['message'] ?? "Erreur de séquestre");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitOpposition(String landId, String reason, String proofHash) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.submitOpposition(landId, reason, proofHash);
      if (res['status'] == 'FAILED') throw Exception(res['message'] ?? "Erreur d'opposition");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> giveLocalAdvice(String landId, String comment, String action) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.giveLocalAdvice(landId, comment, action);
      if (res['status'] == 'FAILED') throw Exception(res['message'] ?? "Erreur d'avis local");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> notaryValidate(String landId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final signature = generateSecureSignature(landId, "NOTARY_VALIDATED");
      final res = await ApiService.notaryValidate(landId, signature);
      if (res['status'] == 'FAILED') throw Exception(res['message'] ?? "Erreur notaire");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ministryApprove(String landId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final signature = generateSecureSignature(landId, "FINALIZED");
      final res = await ApiService.ministryApprove(landId, signature);
      if (res['status'] == 'FAILED') throw Exception(res['message'] ?? "Erreur ministérielle");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> notifyHeritage(String landId, String deathCertId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.notifyHeritage(landId, deathCertId);
      if (res['status'] == 'FAILED') throw Exception(res['message'] ?? "Erreur notification héritage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fragmentHeritage(String landId, List<Map<String, dynamic>> heirs) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.fragmentHeritage(landId, heirs);
      if (res['status'] == 'FAILED') throw Exception(res['message'] ?? "Erreur fragmentation");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerOwner({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String? idRecto,
    required String? idVerso,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.registerOwner({
        'username': username,
        'phone': phone,
        'email': email,
        'password': password,
        'id_recto': idRecto,
        'id_verso': idVerso,
      });
      if (res['status'] != 'PENDING') {
        throw Exception(res['message'] ?? "Erreur lors de l'inscription");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signalFraud(String? parcelId, String? cadastralId, String reason) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.signalFraud({
        'parcel_id': parcelId,
        'cadastral_id': cadastralId,
        'reason': reason,
      });
      if (res['error'] != null) {
        throw Exception(res['error']);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LandService() {
    // Initial check could be here if using local storage for tokens
  }

  Future<void> login(String username, String password) async {
    try {
      final res = await ApiService.login(username, password);
      _isOffline = res['is_offline'] == true;
      if (res.containsKey('token')) {
        _currentUser = AppUser(
          uid: 'UID-${res['user']?['id'] ?? '1'}',
          email: '$username@foncierchain.cg',
          displayName: username.toUpperCase(),
          role: res['user']?['role'] ?? 'AGENT',
        );
        _userRole = _currentUser!.role;
        notifyListeners();
      } else {
        throw Exception(res['error'] ?? "Identifiants invalides");
      }
    } catch (e) {
      debugPrint("Erreur Auth: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userRole = 'CITIZEN';
    _simulatedRole = null;
    notifyListeners();
  }

  String generateSecureSignature(String parcelId, String targetStatus) {
    // Requirements: SECURED-[HMAC_SHA256(parcelId:targetStatus, secret)]
    final secret = "FONCIERCHAIN-SECRET-2026";
    final data = "$parcelId:$targetStatus:$secret";
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes).toString();
    return "SECURED-$hash";
  }

  String? _lastSearchError;
  String? get lastSearchError => _lastSearchError;

  Future<List<Parcel>> searchParcels(String query) async {
    _lastSearchError = null;
    notifyListeners();
    try {
      final results = await ApiService.citizenVerify(query);
      if (results is Map && results.containsKey('error')) {
        _lastSearchError = results['error'];
        notifyListeners();
        return [];
      }
      if (results is List) {
        return results.map((item) => Parcel.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Erreur Search: $e");
      _lastSearchError = "Une erreur est survenue lors de la recherche";
      notifyListeners();
      return [];
    }
  }

  Future<List<TransactionHistory>> getHistory(String parcelId) async {
    try {
      final res = await ApiService.getLandHistory(parcelId);
      final dynamic historyData = res['history'] ?? res['data'] ?? [];
      if (historyData is List) {
        return historyData.map((item) => TransactionHistory.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      debugPrint("Erreur History: $e");
    }
    return [];
  }

  Future<void> initiateDraft({
    required String parcelId,
    required String ownerId,
    required String city,
    required String neighborhood,
    required String cadastralId,
    required double area,
    required double price,
    required String address,
    required String signatureV2,
    required String documentHash,
    double? lat,
    double? lng,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.createDraft({
        'parcelId': parcelId,
        'cadastralId': cadastralId,
        'owner': ownerId,
        'city': city,
        'neighborhood': neighborhood,
        'surface': area,
        'price': price,
        'signatureV2': generateSecureSignature(parcelId, "DRAFT"),
        'documentHash': documentHash,
        'address': address,
        'lat': lat ?? -4.26, 
        'lng': lng ?? 15.28
      });
      _isOffline = response['is_offline'] == true;

      if (response['status'] == 'FAILED') {
        throw Exception(response['message'] ?? "Erreur d'initiation");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Draft: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> validateCommunity(String parcelId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final signature = generateSecureSignature(parcelId, "COMMUNITY_VALIDATED");
      final response = await ApiService.validateLand(parcelId, signature);
      if (response['status'] == 'FAILED') {
        throw Exception(response['message'] ?? "Erreur de validation");
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Validation: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> finalizeLand(String parcelId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final signature = generateSecureSignature(parcelId, "FINALIZED");
      final response = await ApiService.finalizeLand(parcelId, signature);
      if (response['status'] == 'FAILED') {
        throw Exception(response['message'] ?? "Erreur de finalisation");
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Finalisation: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> transferProperty(String parcelId, String newOwnerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.mutateLand(parcelId, newOwnerId);
      if (res['status'] == 'FAILED') {
        throw Exception(res['message'] ?? "Erreur de mutation");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reportDispute(String parcelId, String reason) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.reportDispute(parcelId, reason, _currentUser!.uid);
      if (res['status'] == 'FAILED') {
        throw Exception(res['message'] ?? "Erreur lors du signalement");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    try {
      final res = await ApiService.getReports();
      if (res['alerts'] != null) {
        return List<Map<String, dynamic>>.from(res['alerts']);
      }
    } catch (e) {
      debugPrint("Reports error: $e");
    }
    return [];
  }
}
