import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';
import 'package:instagram/features/Profile/logics/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _onDone() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final cubit = context.read<ProfileCubit>();
      String newPhotoUrl = widget.user.photoUrl;

      if (_selectedImage != null) {
        final uploadedUrl = await cubit.uploadProfilePhoto(
          _selectedImage!,
          widget.user.uid,
        );
        newPhotoUrl = uploadedUrl;
      }

      // Create updated profile
      final updated = widget.user.copyWith(
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        photoUrl: newPhotoUrl,
      );

      await cubit.saveEdits(updated);

      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
            onPressed: _onDone,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (widget.user.photoUrl.isNotEmpty
                            ? NetworkImage(widget.user.photoUrl)
                            : null)
                        as ImageProvider<Object>?,
              child: (_selectedImage == null && widget.user.photoUrl.isEmpty)
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: "Username"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(labelText: "Bio"),
          ),
        ],
      ),
    );
  }
}
