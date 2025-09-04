import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Data/post_repository.dart';
import 'package:instagram/features/Post/logics/post_cubit.dart';
import 'package:instagram/features/Post/logics/post_state.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';
import 'package:instagram/features/Profile/Data/profile_repository.dart';
import 'package:instagram/features/Profile/Presentation/profile_post_preview_screen.dart';
import 'package:instagram/features/Profile/logics/profile_cubit.dart';
import 'package:instagram/features/Profile/logics/profile_state.dart';
import 'edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/services/firebase_storage.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProfileCubit(
            repository: ProfileRepository(
              firestore: FirebaseFirestore.instance,
              storage: FirebaseStorageService.instance,
            ),
            currentUserId: currentUserId,
          )..loadUserProfile(uid),
        ),
        BlocProvider(create: (_) => PostCubit(PostRepository())..fetchPosts()),
      ],
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
              appBar: AppBar(
                title: Text(user.username),
                automaticallyImplyLeading: false,
                centerTitle: false,
              ),
              body: ListView(
                children: [
                  _header(context, user),
                  _bio(user),
                  _actions(context, user, state.isCurrentUser),
                  const Divider(),
                  _userPostsGrid(context, user.uid),
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

  Widget _header(BuildContext ctx, ProfileModel user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (user.bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(user.bio),
          ),
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

  Widget _stat(String label, int count) => Column(
    children: [
      Text(
        "$count",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Text(label),
    ],
  );

  Widget _userPostsGrid(BuildContext ctx, String userId) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is PostLoaded) {
          final posts = ctx.read<PostCubit>().getUserPosts(state.posts, userId);

          if (posts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text("No posts yet")),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final post = posts[index];
              final isSelf = userId == currentUserId;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePostPreviewScreen(
                        posts: posts,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                onLongPress: isSelf
                    ? () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Post"),
                            content: const Text(
                              "Are you sure you want to delete this post?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<PostCubit>().deletePost(post.id);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                child: Image.network(post.imageUrl, fit: BoxFit.cover),
              );
            },
          );
        }

        if (state is PostError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("Error: ${state.message}")),
          );
        }

        return const SizedBox();
      },
    );
  }
}
