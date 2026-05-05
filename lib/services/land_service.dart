import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:latlong2/latlong.dart';
import 'api_service.dart';

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

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoURL,
    this.isKYCVerified = false,
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
  final String? signatureV1;
  final String? signatureV2;
  final String? signatureV3;
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
    this.signatureV1,
    this.signatureV2,
    this.signatureV3,
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
      signatureV1: data['signature_v1'],
      signatureV2: data['signature_v2'],
      signatureV3: data['signature_v3'],
      documentHash: data['hash'] ?? data['documentHash'],
      txId: data['hash'],
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
      if (res['status'] == 'SUCCESS' && res['data'] != null) {
        Map<String, List<String>> newData = {};
        (res['data'] as Map).forEach((key, value) {
          newData[key.toString()] = List<String>.from(value);
        });
        _congoGeoData = newData;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("GeoData error: $e");
    }
  }

  Future<void> verifyKYC(String idNumber) async {
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
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
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

  Future<List<Parcel>> searchParcels(String query) async {
    try {
      final results = await ApiService.citizenVerify(query);
      return results.map((item) => Parcel.fromMap(item)).toList();
    } catch (e) {
      debugPrint("Erreur Search: $e");
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
}
