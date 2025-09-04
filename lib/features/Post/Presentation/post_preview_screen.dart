import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/logics/post_cubit.dart';
import 'package:instagram/features/Post/logics/post_state.dart';

class PostPreviewScreen extends StatefulWidget {
  final String currentUserId;
  final List<File> imageFiles;

  const PostPreviewScreen({
    super.key,
    required this.currentUserId,
    required this.imageFiles,
  });

  @override
  State<PostPreviewScreen> createState() => _PostPreviewScreenState();
}

class _PostPreviewScreenState extends State<PostPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isPosting = false;

  Future<void> _createPosts() async {
    if (_isPosting) return;
    setState(() => _isPosting = true);

    try {
      final postCubit = context.read<PostCubit>();

      for (final file in widget.imageFiles) {
        final post = PostModel(
          id: '',
          userId: widget.currentUserId,
          profileName: '',
          userPhotoUrl: '',
          imageUrl: '',
          caption: _captionController.text.trim(),
          createdAt: DateTime.now(),
        );

        await postCubit.createPost(post, imageFile: file);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Posts created successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to post: $e")));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Preview"),
          actions: [
            TextButton(
              onPressed: _isPosting ? null : _createPosts,
              child: Text(
                _isPosting ? "Posting..." : "Post",
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),

            AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                itemCount: widget.imageFiles.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      widget.imageFiles[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
