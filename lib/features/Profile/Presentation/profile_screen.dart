import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';
import 'package:instagram/features/Profile/Data/profile_repository.dart';
import 'package:instagram/features/Profile/logics/profile_cubit.dart';
import 'package:instagram/features/Profile/logics/profile_state.dart';
import 'edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final String uid;
  final String currentUserId;

  const ProfileScreen({
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

          if (state is ProfileLoaded) {
            final user = state.user;
            return Scaffold(
              appBar: AppBar(title: Text(user.username)),
              body: ListView(
                children: [
                  _header(context, user, state.isCurrentUser),
                  _bio(user),
                  _actions(context, user, state.isCurrentUser),
                  const Divider(),
                  _postsGrid(user),
                ],
              ),
            );
          }

          if (state is ProfileError) {
            return Scaffold(
              body: Center(child: Text("Error: ${state.message}")),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _header(BuildContext ctx, ProfileModel user, bool isSelf) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
      ),
    );
  }

  Widget _bio(ProfileModel user) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (user.bio.isNotEmpty) Text(user.bio),
      ],
    ),
  );

  Widget _actions(BuildContext ctx, ProfileModel user, bool isSelf) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton(
        onPressed: () async {
          if (isSelf) {
            final updated = await Navigator.push<ProfileModel?>(
              ctx,
              MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
            );
            if (updated != null && ctx.mounted) {
              await ctx.read<ProfileCubit>().saveEdits(updated);
            }
          } else {
            await ctx.read<ProfileCubit>().followUnfollow(user.uid);
          }
        },
        child: Text(isSelf ? "Edit Profile" : "Follow"),
      ),
    );
  }

  Widget _postsGrid(ProfileModel user) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: user.postsCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (_, i) => Image.network(user.posts[i], fit: BoxFit.cover),
    );
  }

  Widget _stat(String label, int count) => Column(
    children: [
      Text("$count", style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(label),
    ],
  );
}
