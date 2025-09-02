import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  final List<Map<String, dynamic>> comments;

  const CommentList({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(child: Text("No comments yet"));
    }

    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final userName = comment['userName'] ?? "Unknown";
        final text = comment['text'] ?? "";
        final userPhotoUrl = comment['userPhotoUrl'] ?? "";

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
          subtitle: Text(text),
        );
      },
    );
  }
}
