import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>?> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final snapshot = await firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return {
        'uid': doc.id,
        'username': data['username']?.toString() ?? 'No name',
        'email': data['email']?.toString() ?? '',
        'profileImage':
            (data['profileImage'] != null &&
                data['profileImage'].toString().isNotEmpty)
            ? data['profileImage'].toString()
            : null,
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;

      return {
        'uid': doc.id,
        'username': data['username']?.toString() ?? 'No name',
        'email': data['email']?.toString() ?? '',
        'profileImage':
            (data['profileImage'] != null &&
                data['profileImage'].toString().isNotEmpty)
            ? data['profileImage'].toString()
            : null,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⚠️ Error fetching user: $e");
      }
      return null;
    }
  }
}
