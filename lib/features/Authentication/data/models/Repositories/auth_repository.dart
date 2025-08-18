import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/features/Authentication/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserModel?> signUp(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = UserModel(
        uid: cred.user!.uid,
        email: email,
        username: username,
      );
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = UserModel(
        uid: cred.user!.uid,
        email: cred.user!.email ?? '',
        username: cred.user!.displayName ?? '',
      );
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
