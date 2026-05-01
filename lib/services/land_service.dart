import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'api_service.dart';

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

  factory Parcel.fromFirestore(Map<String, dynamic> data) {
    return Parcel(
      id: data['id'] ?? data['parcelId'] ?? '',
      ownerName: data['ownerName'] ?? data['owner'] ?? '',
      ownerId: data['ownerId'] ?? 'UID-TEMP',
      city: data['city'] ?? 'Brazzaville',
      neighborhood: data['neighborhood'] ?? '',
      cadastralId: data['cadastralId'] ?? '',
      area: (data['area'] ?? data['surface'] ?? 0).toDouble(),
      price: (data['price'] ?? 0).toDouble(),
      usage: data['usage'] ?? '',
      address: data['address'] ?? '',
      status: data['status'] ?? 'DRAFT',
      signatureV1: data['signatureV1'] ?? data['signature_v1'],
      signatureV2: data['signatureV2'] ?? data['signature_v2'],
      signatureV3: data['signatureV3'] ?? data['signature_v3'],
      documentHash: data['documentHash'] ?? data['hash'],
      txId: data['txId'],
      lastUpdate: data['lastUpdate'] is Timestamp 
          ? (data['lastUpdate'] as Timestamp).toDate() 
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

  factory TransactionHistory.fromFirestore(Map<String, dynamic> data) {
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
  late final FirebaseFirestore _db;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    _db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'ai-studio-66c2610a-a070-4530-8833-e441559e6519',
    );

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _syncUserProfile(user);
      } else {
        _userRole = 'CITIZEN';
        _simulatedRole = null;
      }
      notifyListeners();
    });
  }

  Future<void> _syncUserProfile(User user) async {
    try {
      final docRef = _db.collection('users').doc(user.uid);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        String role = 'CITIZEN';
        if (user.email == 'hamsterlecurieux25@gmail.com') {
          role = 'ADMIN';
        }
        
        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'role': role,
          'displayName': user.displayName ?? 'Utilisateur FoncierChain',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _userRole = role;
      } else {
        _userRole = doc.data()?['role'] ?? 'CITIZEN';
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur de synchronisation profil: $e");
    }
  }

  void _handleFirestoreError(dynamic error, OperationType op, String path) {
    final Map<String, dynamic> errInfo = {
      'error': error.toString(),
      'operationType': op.toString().split('.').last.toLowerCase(),
      'path': path,
      'authInfo': {
        'userId': _auth.currentUser?.uid,
        'email': _auth.currentUser?.email,
        'emailVerified': _auth.currentUser?.emailVerified,
      }
    };
    final jsonErr = jsonEncode(errInfo);
    debugPrint("Firestore Error Debug: $jsonErr");
    throw Exception(jsonErr);
  }

  User? get currentUser => _auth.currentUser;

  String generateSecureHash(String parcelId, String ownerName) {
    final timestamp = DateTime.now().toIso8601String();
    final bytes = utf8.encode("$parcelId-$ownerName-$timestamp");
    return sha256.convert(bytes).toString();
  }

  Future<List<Parcel>> searchParcels(String query) async {
    const String path = 'parcels';
    try {
      final qId = await _db.collection(path).where('id', isEqualTo: query.toUpperCase()).get();
      if (qId.docs.isNotEmpty) {
        return qId.docs.map((doc) => Parcel.fromFirestore(doc.data())).toList();
      }

      final qAddr = await _db.collection(path)
          .where('address', isGreaterThanOrEqualTo: query)
          .where('address', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return qAddr.docs.map((doc) => Parcel.fromFirestore(doc.data())).toList();
    } catch (e) {
      _handleFirestoreError(e, OperationType.LIST, path);
      return [];
    }
  }

  Stream<List<TransactionHistory>> getHistory(String parcelId) {
    return _db.collection('parcels').doc(parcelId).collection('history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TransactionHistory.fromFirestore(doc.data())).toList());
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
    const String path = 'parcels';
    final docRef = _db.collection(path).doc(parcelId);
    
    try {
      final doc = await docRef.get();
      if (doc.exists) {
        throw Exception("DOUBLE_ATTRIBUTION: Cette parcelle ($parcelId) est déjà enregistrée.");
      }

      await docRef.set({
        'id': parcelId,
        'ownerName': ownerName,
        'ownerId': ownerId,
        'city': 'Brazzaville',
        'neighborhood': neighborhood,
        'cadastralId': cadastralId,
        'area': area,
        'price': price,
        'usage': usage,
        'address': address,
        'status': 'DRAFT',
        'signatureV2': signatureV2,
        'documentHash': documentHash,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _handleFirestoreError(e, OperationType.WRITE, "$path/$parcelId");
    }
  }

  Future<void> validateCommunity(String parcelId, String signatureV3) async {
    const String path = 'parcels';
    try {
      await _db.collection(path).doc(parcelId).update({
        'status': 'COMMUNITY_VALIDATED',
        'signatureV3': signatureV3,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _handleFirestoreError(e, OperationType.UPDATE, "$path/$parcelId");
    }
  }

  Future<void> finalizeLand(String parcelId, String signatureV1) async {
    const String path = 'parcels';
    try {
      final txId = generateSecureHash(parcelId, "FINALIZED");
      await _db.collection(path).doc(parcelId).update({
        'status': 'FINALIZED',
        'signatureV1': signatureV1,
        'txId': txId,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      await _db.collection(path).doc(parcelId).collection('history').add({
        'previousOwner': 'ÉTAT',
        'newOwner': 'PREMIER PROPRIÉTAIRE',
        'date': DateTime.now().toIso8601String(),
        'type': 'IMMATRICULATION',
        'documentHash': txId,
      });
    } catch (e) {
      _handleFirestoreError(e, OperationType.UPDATE, "$path/$parcelId");
    }
  }

  Future<void> transferProperty(String parcelId, String newOwnerName, String newOwnerId) async {
    const String path = 'parcels';
    try {
      final parcelDoc = await _db.collection(path).doc(parcelId).get();
      if (!parcelDoc.exists) throw Exception("Parcelle introuvable");
      
      final parcel = Parcel.fromFirestore(parcelDoc.data()!);
      if (parcel.status != 'FINALIZED') {
        throw Exception("PROTOCOLE_DENIED: Seules les parcelles finalisées peuvent être transférées.");
      }

      final txId = generateSecureHash(parcelId, newOwnerName);
      final previousOwner = parcel.ownerName;

      await _db.collection(path).doc(parcelId).update({
        'ownerName': newOwnerName,
        'ownerId': newOwnerId,
        'txId': txId,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      await _db.collection(path).doc(parcelId).collection('history').add({
        'previousOwner': previousOwner,
        'newOwner': newOwnerName,
        'date': DateTime.now().toIso8601String(),
        'type': 'MUTATION',
        'documentHash': txId,
      });
    } catch (e) {
      _handleFirestoreError(e, OperationType.UPDATE, "$path/$parcelId");
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await _auth.signInWithPopup(googleProvider);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la connexion Google: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
