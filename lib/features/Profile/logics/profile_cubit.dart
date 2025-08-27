import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Profile/Data/profile_repository.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';
import 'package:instagram/features/Profile/logics/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  final String currentUserId;

  ProfileCubit({required this.repository, required this.currentUserId})
    : super(const ProfileInitial());

  Future<void> loadUserProfile(String uid) async {
    emit(const ProfileLoading());
    try {
      final profile = await repository.getUserProfile(uid);
      if (profile != null) {
        emit(ProfileLoaded(user: profile, isCurrentUser: uid == currentUserId));
      } else {
        emit(const ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> followUnfollow(String targetUid) async {
    try {
      await repository.followUser(
        currentUid: currentUserId,
        targetUid: targetUid,
      );
      await loadUserProfile(targetUid);
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> saveEdits(ProfileModel updated) async {
    try {
      await repository.updateProfile(updated);
      await loadUserProfile(updated.uid);
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<String> updateProfilePhoto(File file, String uid) async {
    emit(const ProfileLoading());
    try {
      final downloadUrl = await repository.updateProfilePhoto(
        uid: uid,
        file: file,
      );
      await loadUserProfile(uid);
      return downloadUrl;
    } catch (e) {
      emit(ProfileError(e.toString()));
      rethrow;
    }
  }
}
