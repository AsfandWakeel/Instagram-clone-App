import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/logics/post_cubit.dart';
import 'package:instagram/features/Post/logics/post_state.dart';

class CreatePostScreen extends StatefulWidget {
  final String currentUserId;
  const CreatePostScreen({super.key, required this.currentUserId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _pickImages();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty && mounted) {
      setState(() {
        _imageFiles = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageFiles.isEmpty) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Create Post"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  "New Post",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PostPreviewScreen(
      currentUserId: widget.currentUserId,
      imageFiles: _imageFiles,
    );
  }
}

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
        appBar: AppBar(title: const Text("Preview")),
        body: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
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
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _createPosts,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isPosting ? "Posting..." : "Post"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
