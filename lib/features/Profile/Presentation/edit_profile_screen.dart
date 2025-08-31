import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';
import 'package:instagram/features/Profile/logics/profile_cubit.dart';
import 'package:instagram/features/Profile/logics/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  File? _imageFile;

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
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated successfully")),
            );
            Navigator.pop(context, state.user);
          } else if (state is ProfileError) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (widget.user.photoUrl.isNotEmpty
                                    ? NetworkImage(widget.user.photoUrl)
                                    : const AssetImage(
                                        "assets/default_avatar.png",
                                      ))
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a username";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: "Bio"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String photoUrl = widget.user.photoUrl;
                        final profileCubit = context.read<ProfileCubit>();

                        // agar naya photo select hua hai to upload karo
                        if (_imageFile != null) {
                          photoUrl = await profileCubit.uploadProfilePhoto(
                            _imageFile!,
                            widget.user.uid,
                          );
                        }

                        // updated profile banate hain
                        final updatedProfile = widget.user.copyWith(
                          username: _usernameController.text,
                          bio: _bioController.text,
                          photoUrl: photoUrl,
                        );

                        // cubit se save karo
                        await profileCubit.saveEdits(updatedProfile);

                        // context ka safe use
                        if (!mounted) return;
                      }
                    },
                    child: state is ProfileLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
