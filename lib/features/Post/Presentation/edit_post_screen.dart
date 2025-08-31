import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/logics/post_cubit.dart';
import 'package:instagram/features/Post/logics/post_state.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _captionController;
  File? _newImage;
  bool _isUpdating = false;

  @override
  void initState() {
    _captionController = TextEditingController(text: widget.post.caption);
    super.initState();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null && mounted) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updatePost() async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    final updatedPost = PostModel(
      id: widget.post.id,
      userId: widget.post.userId,
      profileName: widget.post.profileName,
      userPhotoUrl: widget.post.userPhotoUrl,
      imageUrl: widget.post.imageUrl,
      caption: _captionController.text.trim(),
      createdAt: widget.post.createdAt,
      likes: widget.post.likes,
      comments: widget.post.comments,
    );

    try {
      await context.read<PostCubit>().updatePost(
        updatedPost,
        imageFile: _newImage,
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostCubit, PostState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is PostSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is PostError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Post'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _newImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _newImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.post.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _captionController,
                hintText: 'Edit your caption...',
              ),
              const SizedBox(height: 16),
              AppButton(
                text: _isUpdating ? 'Updating...' : 'Update',
                onPressed: _isUpdating ? null : _updatePost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
