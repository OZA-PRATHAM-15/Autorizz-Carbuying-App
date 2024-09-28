import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create or update a user document
  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error setting user data: $e');
    }
  }

  // Get user data
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _db.collection('users').doc(uid).get();
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }
}
