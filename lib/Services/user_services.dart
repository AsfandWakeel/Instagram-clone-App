import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
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
        'username': data['username'] ?? '',
        'email': data['email'] ?? '',
        'profileImage': data['profileImage'] ?? '',
      };
    }).toList();
  }
}
