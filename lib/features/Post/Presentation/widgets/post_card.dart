import 'package:flutter/material.dart';
import 'package:instagram/features/Post/Data/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const PostCard({super.key, required this.post, this.onLike, this.onComment});

  Widget networkImage(String url) {
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userPhotoUrl.isNotEmpty
                  ? NetworkImage(post.userPhotoUrl)
                  : null,
              child: post.userPhotoUrl.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              post.profileName.isNotEmpty ? post.profileName : "Unknown User",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          networkImage(post.imageUrl),

          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(post.caption),
            ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: onLike,
              ),
              IconButton(icon: const Icon(Icons.comment), onPressed: onComment),
            ],
          ),
        ],
      ),
    );
  }
}
