import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Authentication/data/repository/auth_repository.dart';
import 'package:instagram/features/Authentication/logics/auth_state.dart';
import 'package:instagram/features/Authentication/data/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> signUp(String email, String password, String username) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUp(email, password, username);
      if (user != null) {
        emit(AuthLoggedIn(user: user));
      } else {
        emit(AuthError("Signup failed"));
      }
    } catch (e) {
      emit(AuthError("Signup error: $e"));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.loginWithEmail(email, password);
      if (user != null) {
        emit(AuthLoggedIn(user: user));
      } else {
        emit(AuthError("Login failed"));
      }
    } catch (e) {
      emit(AuthError("Login error: $e"));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final userCred = await authRepository.loginWithGoogle();
      if (userCred == null || userCred.user == null) {
        emit(AuthError('Google Sign In Failed'));
        return;
      }

      final user = UserModel(
        uid: userCred.user!.uid,
        email: userCred.user!.email ?? '',
        username: userCred.user!.displayName ?? '',
        photoUrl: userCred.user!.photoURL,
      );

      emit(AuthLoggedIn(user: user));
    } catch (e) {
      emit(AuthError("Google login error: $e"));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError("Logout failed: $e"));
    }
  }
}
