import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'api_service.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String? photoURL;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoURL,
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

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;
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

  void signOut() {
    _currentUser = null;
    _userRole = 'CITIZEN';
    _simulatedRole = null;
    notifyListeners();
  }

  String generateSecureHash(String parcelId, String ownerName) {
    final timestamp = DateTime.now().toIso8601String();
    final bytes = utf8.encode("$parcelId-$ownerName-$timestamp");
    return sha256.convert(bytes).toString();
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
      final history = await ApiService.getLandHistory(parcelId);
      if (history is List) {
        return history.map((item) => TransactionHistory.fromMap(item)).toList();
      }
    } catch (e) {
      debugPrint("Erreur History: $e");
    }
    return [];
  }

  Future<void> initiateDraft({
    required String parcelId,
    required String ownerName,
    required String ownerId,
    required String neighborhood,
    required String cadastralId,
    required double area,
    required double price,
    required String usage,
    required String address,
    required String signatureV2,
    required String documentHash,
  }) async {
    try {
      await ApiService.createDraft({
        'parcelId': parcelId,
        'owner': ownerName,
        'neighborhood': neighborhood,
        'cadastralId': cadastralId,
        'surface': area,
        'price': price,
        'usage': usage,
        'signature_v2': signatureV2,
        'hash': documentHash,
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Draft: $e");
      rethrow;
    }
  }

  Future<void> validateCommunity(String parcelId, String signatureV3) async {
    try {
      await ApiService.validateLand(parcelId, signatureV3);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Validation: $e");
      rethrow;
    }
  }

  Future<void> finalizeLand(String parcelId, String signatureV1) async {
    try {
      await ApiService.finalizeLand(parcelId, signatureV1);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Finalisation: $e");
      rethrow;
    }
  }

  Future<void> transferProperty(String parcelId, String newOwnerName, String newOwnerId) async {
    // Current API might not have a transfer endpoint yet, but we'd call it here
    notifyListeners();
  }
}
