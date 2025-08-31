import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/logics/post_cubit.dart';

// ⚠️ Make sure filename is comment_list.dart (no spaces)
import 'package:instagram/features/Post/Presentation/widgets/comment_list.dart';
import 'package:instagram/features/Post/Presentation/widgets/like_button.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUserId;

  const PostCard({super.key, required this.post, required this.currentUserId});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Widget _networkImage(String url) {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image, size: 50));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.likes.contains(widget.currentUserId);
    final likeCount = widget.post.likes.length;
    final commentCount = widget.post.comments.length;

    // 🔄 Map comments to always have 'text' key (fallback to 'comment')
    final normalizedComments = widget.post.comments.map((c) {
      return {
        'userPhotoUrl': c['userPhotoUrl'] ?? '',
        'username': c['username'] ?? 'Unknown',
        'text': (c['text'] ?? c['comment'] ?? '').toString(),
        'createdAt': c['createdAt'],
      };
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (profile)
          ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundImage: widget.post.userPhotoUrl.isNotEmpty
                  ? NetworkImage(widget.post.userPhotoUrl)
                  : null,
              child: widget.post.userPhotoUrl.isEmpty
                  ? const Icon(Icons.person, size: 22)
                  : null,
            ),
            title: Text(
              widget.post.profileName.isNotEmpty
                  ? widget.post.profileName
                  : "Unknown User",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${widget.post.createdAt.toLocal()}".split(" ")[0],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Icon(Icons.more_vert),
          ),

          // Image
          _networkImage(widget.post.imageUrl),

          // Actions row — Like + Comment counts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                LikeButton(
                  isLiked: isLiked,
                  onTap: () {
                    context.read<PostCubit>().likePost(
                      widget.post.id,
                      widget.currentUserId,
                    );
                  },
                ),
                Text("$likeCount"),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {}, // (optional) open full comments screen
                ),
                Text("$commentCount"),
              ],
            ),
          ),

          // Caption
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: widget.post.profileName.isNotEmpty
                          ? "${widget.post.profileName} "
                          : "User ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
            ),

          // Comments list
          if (normalizedComments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CommentList(comments: normalizedComments),
            ),

          // Comment input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: "Add a comment…",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _commentCtrl.text.trim();
                    if (text.isEmpty) return;

                    context.read<PostCubit>().addComment(
                      widget.post.id,
                      widget.currentUserId,
                      text,
                    );

                    _commentCtrl.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
