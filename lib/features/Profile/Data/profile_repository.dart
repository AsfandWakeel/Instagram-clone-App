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
    final currentRef = firestore.collection("users").doc(currentUid);
    final targetRef = firestore.collection("users").doc(targetUid);

    await firestore.runTransaction((tx) async {
      final currentSnap = await tx.get(currentRef);
      final targetSnap = await tx.get(targetRef);

      if (!currentSnap.exists || !targetSnap.exists) return;

      final following = List<String>.from(currentSnap['following'] ?? []);

      if (following.contains(targetUid)) {
        // Unfollow
        tx.update(currentRef, {
          'following': FieldValue.arrayRemove([targetUid]),
        });
        tx.update(targetRef, {
          'followers': FieldValue.arrayRemove([currentUid]),
        });
      } else {
        tx.update(currentRef, {
          'following': FieldValue.arrayUnion([targetUid]),
        });
        tx.update(targetRef, {
          'followers': FieldValue.arrayUnion([currentUid]),
        });
      }
    });
  }

  Future<String> uploadProfileImagePlaceholder(
    String uid,
    String localFilePath,
  ) async {
    return "https://via.placeholder.com/150.png?text=Profile";
  }
}
