import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Feed/logics/feed_cubit.dart';
import 'package:instagram/features/Feed/logics/feed_state.dart';
import 'package:instagram/features/Feed/presentation/widgets/feed_post_tile.dart';

class FeedScreen extends StatefulWidget {
  final String currentUserId;

  const FeedScreen({super.key, required this.currentUserId});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FeedCubit>().fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FeedCubit, FeedState>(
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FeedError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is FeedLoaded) {
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
                final post = posts[index];

                return FeedPostTile(
                  post: post,
                  currentUserId: widget.currentUserId,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
