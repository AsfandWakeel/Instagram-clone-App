import 'package:flutter/material.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:intl/intl.dart';

class ProfilePostPreviewScreen extends StatelessWidget {
  final List<PostModel> posts;
  final int initialIndex;

  const ProfilePostPreviewScreen({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        final position = initialIndex * 500.0;
        scrollController.jumpTo(position);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        controller: scrollController,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: post.userPhotoUrl.isNotEmpty
                          ? NetworkImage(post.userPhotoUrl)
                          : const AssetImage("assets/default_profile.png")
                                as ImageProvider,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.profileName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.mode_comment_outlined,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "${post.likes.length} likes",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${post.profileName} ",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: post.caption,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),

              if (post.comments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "View all ${post.comments.length} comments",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 4),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  DateFormat('MMM d, yyyy').format(post.createdAt),
                  style: const TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
