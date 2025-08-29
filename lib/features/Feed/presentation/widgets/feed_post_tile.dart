import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Feed/logics/feed_cubit.dart';
import 'package:instagram/features/Post/Data/post_model.dart';

class FeedPostTile extends StatelessWidget {
  final PostModel post;
  final String currentUserId;

  const FeedPostTile({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final TextEditingController commentController = TextEditingController();
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 350,
            child: Column(
              children: [
                const Text(
                  "Comments",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: post.comments.length,
                    itemBuilder: (_, index) {
                      final comment = post.comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            comment['userPhotoUrl'] ?? '',
                          ),
                        ),
                        title: Text(comment['username'] ?? ''),
                        subtitle: Text(comment['text'] ?? ''),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: "Add a comment",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final commentText = commentController.text.trim();
                        if (commentText.isEmpty) return;

                        context.read<FeedCubit>().addComment(
                          post.id,
                          currentUserId,
                          commentText,
                        );

                        commentController.clear();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = post.likes.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.userPhotoUrl),
            ),
            title: Text(post.profileName),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image, size: 50)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.caption),
          ),
          Row(
            children: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isLiked),
                    color: isLiked ? Colors.red : Colors.black,
                  ),
                ),
                onPressed: () {
                  context.read<FeedCubit>().likePost(post.id, currentUserId);
                },
              ),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () => _showComments(context),
              ),
              const Spacer(),
              Text('${post.likes.length} likes'),
            ],
          ),
        ],
      ),
    );
  }
}
