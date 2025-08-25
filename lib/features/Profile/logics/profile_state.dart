import 'package:instagram/features/Profile/Data/profile_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileModel user;
  final bool isCurrentUser;
  const ProfileLoaded({required this.user, required this.isCurrentUser});
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}
