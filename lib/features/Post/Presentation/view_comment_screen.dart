import 'package:flutter/material.dart';
import 'package:instagram/features/Post/Data/post_model.dart';

class ViewCommentsScreen extends StatelessWidget {
  final PostModel post;

  const ViewCommentsScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: post.comments.isEmpty
          ? const Center(
              child: Text(
                "No comments yet",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: post.comments.length,
              itemBuilder: (context, index) {
                final comment = post.comments[index];

                final userName = comment['userName'] ?? "Unknown";
                final text = comment['text'] ?? "";
                final userPhotoUrl = comment['userPhotoUrl'] ?? "";
                final createdAt = comment['createdAt'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userPhotoUrl.isNotEmpty
                        ? NetworkImage(userPhotoUrl)
                        : const AssetImage("assets/default_avatar.png")
                              as ImageProvider,
                  ),
                  title: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text),
                      if (createdAt != null)
                        Text(
                          createdAt.toString().split(" ")[0],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
