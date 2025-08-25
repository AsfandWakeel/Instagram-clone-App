import 'package:instagram/features/Authentication/data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoggedIn extends AuthState {
  final UserModel user;
  AuthLoggedIn({required this.user});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthLoggedOut extends AuthState {}

class AuthPasswordReset extends AuthState {
  final String email;
  AuthPasswordReset(this.email);
}
