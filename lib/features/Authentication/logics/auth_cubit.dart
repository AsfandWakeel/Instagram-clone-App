import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Authentication/data/models/Repositories/auth_repository.dart';
import 'package:instagram/features/Authentication/logics/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> signUp(String email, String password, String username) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUp(email, password, username);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError("Signup failed"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError("Login failed"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(AuthLoggedOut());
  }
}
