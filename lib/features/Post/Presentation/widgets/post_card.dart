import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/Presentation/widgets/comment_list.dart';
import 'package:instagram/features/Post/Presentation/widgets/like_button.dart';
import 'package:instagram/features/Feed/logics/feed_cubit.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String currentUserId;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required Future<void> Function() onLike,
    required Future<void> Function(dynamic commentText) onComment,
  });

  void _showComments(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                const Text(
                  "Comments",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Expanded(child: CommentList(comments: post.comments)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: "Add a comment",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final text = commentController.text.trim();
                        if (text.isNotEmpty) {
                          context.read<FeedCubit>().addComment(
                            post.id,
                            currentUserId,
                            text,
                            post.userId,
                          );
                          commentController.clear();
                        }
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

          /// Post Image
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image, size: 40)),
            ),
          ),

          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(post.caption),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                LikeButton(
                  isLiked: isLiked,
                  likeCount: post.likes.length,
                  onTap: () {
                    context.read<FeedCubit>().likePost(
                      post.id,
                      currentUserId,
                      post.userId,
                      // removed currentUsername
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => _showComments(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
