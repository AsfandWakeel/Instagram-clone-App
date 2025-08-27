import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  final List<Map<String, dynamic>> comments;

  const CommentList({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) {
        final comment = comments[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(comment['userPhotoUrl'] ?? ''),
          ),
          title: Text(comment['username'] ?? ''),
          subtitle: Text(comment['text'] ?? ''),
        );
      },
    );
  }
}
