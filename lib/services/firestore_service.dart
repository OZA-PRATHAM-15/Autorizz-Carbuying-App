import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user data: $e');
      }
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _db.collection('users').doc(uid).get();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      rethrow;
    }
  }
}
