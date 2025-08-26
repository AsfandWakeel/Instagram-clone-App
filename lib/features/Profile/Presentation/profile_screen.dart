import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';
import 'package:instagram/features/Profile/Data/profile_repository.dart';
import 'package:instagram/features/Profile/Presentation/edit_profile_screen.dart';
import 'package:instagram/features/Profile/logics/profile_cubit.dart';
import 'package:instagram/features/Profile/logics/profile_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SimpleProfileScreen extends StatelessWidget {
  final String uid;
  final String currentUserId;

  const SimpleProfileScreen({
    super.key,
    required this.uid,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        repository: ProfileRepository(firestore: FirebaseFirestore.instance),
        currentUserId: currentUserId,
      )..loadUserProfile(uid),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProfileError) {
            return Scaffold(
              body: Center(child: Text("Error: ${state.message}")),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            final isSelf = state.isCurrentUser;

            return Scaffold(
              appBar: AppBar(
                title: Text(user.username),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _header(user),
                      const SizedBox(height: 16),
                      _bio(user),
                      const SizedBox(height: 16),
                      _actionButton(context, user, isSelf),
                      const Divider(),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _header(ProfileModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : null,
          child: user.photoUrl.isEmpty
              ? const Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat("Posts", user.postsCount),
              _stat("Followers", user.followersCount),
              _stat("Following", user.followingCount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bio(ProfileModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (user.bio.isNotEmpty) Text(user.bio),
      ],
    );
  }

  Widget _actionButton(BuildContext context, ProfileModel user, bool isSelf) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          if (isSelf) {
            final updated = await Navigator.push<ProfileModel?>(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(user: user),
              ),
            );

            if (updated != null && context.mounted) {
              await context.read<ProfileCubit>().saveEdits(updated);
            }
          } else {
            await context.read<ProfileCubit>().followUnfollow(user.uid);
          }
        },
        child: Text(isSelf ? "Edit Profile" : "Follow"),
      ),
    );
  }

  Widget _stat(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label),
      ],
    );
  }
}
