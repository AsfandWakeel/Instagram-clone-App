import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Feed/logics/feed_cubit.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/Presentation/widgets/comment_list.dart';
import 'package:instagram/features/Post/Presentation/widgets/like_button.dart';

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final TextEditingController commentController = TextEditingController();

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Comments",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(child: CommentList(comments: post.comments)),
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    top: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: "Add a comment",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
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
                            post.userId,
                          );

                          commentController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(post.caption),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
