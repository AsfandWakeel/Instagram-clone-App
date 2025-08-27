import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/logics/post_cubit.dart';
import 'package:instagram/features/Post/logics/post_state.dart';
import 'package:instagram/features/Post/Presentation/widgets/post_card.dart';
import 'package:instagram/features/Post/Data/post_model.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PostCubit>().fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PostError) {
          return Center(child: Text("Error: ${state.message}"));
        } else if (state is PostLoaded) {
          final posts = state.posts;

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                "No posts yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final PostModel post = posts[index];
              return PostCard(
                post: post,
                onLike: () {
                  final currentUserId = "currentUserId";
                  final isLiked = post.likes.contains(currentUserId);
                  context.read<PostCubit>().likePost(
                    post.id,
                    currentUserId,
                    isLiked,
                  );
                },
                onComment: () {},
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
