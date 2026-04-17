import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Parcel {
  final String id;
  final String ownerName;
  final double surface;
  final String usage;
  final String address;
  final String hash;
  final String status;

  Parcel({
    required this.id,
    required this.ownerName,
    required this.surface,
    required this.usage,
    required this.address,
    required this.hash,
    required this.status,
  });

  factory Parcel.fromFirestore(Map<String, dynamic> data) {
    return Parcel(
      id: data['id'] ?? '',
      ownerName: data['ownerName'] ?? '',
      surface: (data['surface'] ?? 0).toDouble(),
      usage: data['usage'] ?? '',
      address: data['address'] ?? '',
      hash: data['hash'] ?? '',
      status: data['status'] ?? 'en_attente',
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

class LandService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Hachage immuable (Blockchain)
  String generateSecureHash(String parcelId, String ownerName) {
    final timestamp = DateTime.now().toIso8601String();
    final bytes = utf8.encode("$parcelId-$ownerName-$timestamp");
    return sha256.convert(bytes).toString();
  }

  // Recherche une parcelle par son ID
  Future<Parcel?> verifyParcel(String id) async {
    try {
      final q = await _db.collection('parcels').where('id', 'isEqualTo', id.toUpperCase()).get();
      if (q.docs.isNotEmpty) {
        return Parcel.fromFirestore(q.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint("Error verifying parcel: $e");
      return null;
    }
  }

  // Récupère l'historique des transactions
  Stream<List<TransactionHistory>> getHistory(String parcelId) {
    return _db
        .collection('parcels')
        .doc(parcelId)
        .collection('history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TransactionHistory.fromFirestore(doc.data())).toList());
  }

  // Login via Google (Simulation pour prototype)
  Future<void> loginWithGoogle() async {
    // Dans une app réelle, utilisez google_sign_in
    notifyListeners();
  }
}
