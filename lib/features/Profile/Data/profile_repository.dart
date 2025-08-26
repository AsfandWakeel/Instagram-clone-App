import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore firestore;

  ProfileRepository({required this.firestore});

  Future<ProfileModel?> getUserProfile(String uid) async {
    final doc = await firestore.collection("users").doc(uid).get();

    if (doc.exists) {
      return ProfileModel.fromMap(doc.data()!);
    }

    return null;
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await firestore
        .collection("users")
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> followUser({
    required String currentUid,
    required String targetUid,
  }) async {
    final currentUserRef = firestore.collection("users").doc(currentUid);
    final targetUserRef = firestore.collection("users").doc(targetUid);

    await firestore.runTransaction((transaction) async {
      final currentSnap = await transaction.get(currentUserRef);
      final targetSnap = await transaction.get(targetUserRef);

      if (!currentSnap.exists || !targetSnap.exists) return;

      final following = List<String>.from(currentSnap['following'] ?? []);

      if (following.contains(targetUid)) {
        transaction.update(currentUserRef, {
          'following': FieldValue.arrayRemove([targetUid]),
        });
        transaction.update(targetUserRef, {
          'followers': FieldValue.arrayRemove([currentUid]),
        });
      } else {
        transaction.update(currentUserRef, {
          'following': FieldValue.arrayUnion([targetUid]),
        });
        transaction.update(targetUserRef, {
          'followers': FieldValue.arrayUnion([currentUid]),
        });
      }
    });
  }
}
