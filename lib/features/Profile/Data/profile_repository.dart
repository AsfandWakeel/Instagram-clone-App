import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';
import 'package:instagram/services/firebase_storage.dart';

class ProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorageService storage;

  ProfileRepository({required this.firestore, required this.storage});

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

  Future<String> updateProfilePhoto({
    required String uid,
    required File file,
  }) async {
    final folder = "profile_images/$uid";
    final downloadUrl = await storage.uploadFile(file: file, folder: folder);

    await firestore.collection("users").doc(uid).update({
      "photoUrl": downloadUrl,
    });

    return downloadUrl;
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
