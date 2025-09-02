import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/services/firebase_auth_service.dart';
import 'package:instagram/features/Authentication/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService _firebaseAuthService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepository(this._firebaseAuthService);

  Future<UserModel?> loginWithEmail(String email, String password) async {
    final userModel = await _firebaseAuthService.login(
      email: email,
      password: password,
    );

    if (userModel != null) {
      final userDoc = _firestore.collection("users").doc(userModel.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set(userModel.toMap());
      } else {
        await userDoc.set(userModel.toMap(), SetOptions(merge: true));
      }
    }

    return userModel;
  }

  Future<UserCredential?> loginWithGoogle() async {
    final userCred = await _firebaseAuthService.signInWithGoogle();

    final user = userCred.user;
    if (user != null) {
      final userDoc = _firestore.collection("users").doc(user.uid);
      final docSnapshot = await userDoc.get();

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        username: user.displayName ?? '',
        photoUrl: user.photoURL,
      );

      if (!docSnapshot.exists) {
        await userDoc.set(userModel.toMap());
      } else {
        await userDoc.set(userModel.toMap(), SetOptions(merge: true));
      }
    }

    return userCred;
  }

  Future<UserModel?> signUp(
    String email,
    String password,
    String username,
  ) async {
    final userModel = await _firebaseAuthService.signUp(
      email: email,
      password: password,
      username: username,
    );

    if (userModel != null) {
      await saveUserToFirestore(userModel);
    }

    return userModel;
  }

  Future<void> saveUserToFirestore(UserModel user) async {
    await _firestore.collection("users").doc(user.uid).set(user.toMap());
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuthService.resetPassword(email);
  }

  Future<void> logout() async {
    await _firebaseAuthService.logout();
  }
}
