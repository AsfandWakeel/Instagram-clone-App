import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram/features/Authentication/data/models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize(
      clientId:
          '119689245322-545b5sknkn7sel5hlj79pnmh68k0t05b.apps.googleusercontent.com',
    );
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance
        .authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final user = await _auth.signInWithCredential(credential);
    return user;
  }

  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? _toUserModel(user) : null;
  }

  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().map(
      (firebaseUser) =>
          firebaseUser != null ? _toUserModel(firebaseUser) : null,
    );
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(username);
      await cred.user?.reload();
      return cred.user != null ? _toUserModel(cred.user!) : null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign Up failed: ${e.message}');
    }
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user != null ? _toUserModel(cred.user!) : null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  UserModel _toUserModel(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      username: user.displayName ?? '',
    );
  }
}
