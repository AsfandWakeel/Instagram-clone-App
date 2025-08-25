import 'package:flutter/material.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: () {
              final updated = widget.user.copyWith(
                username: _usernameController.text.trim(),
                bio: _bioController.text.trim(),
              );
              Navigator.pop(context, updated);
            },
            child: const Text("Done"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: widget.user.photoUrl.isNotEmpty
                ? NetworkImage(widget.user.photoUrl)
                : null,
            child: widget.user.photoUrl.isEmpty
                ? const Icon(Icons.person, size: 50)
                : null,
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
