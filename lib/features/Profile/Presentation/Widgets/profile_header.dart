import 'package:flutter/material.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel user;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onFollowToggle;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isCurrentUser,
    this.onEdit,
    this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : null,
          child: user.photoUrl.isEmpty
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 10),

        Text(
          user.username,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),

        if (user.bio.isNotEmpty)
          Text(
            user.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stat("Posts", user.postsCount),
            _stat("Followers", user.followersCount),
            _stat("Following", user.followingCount),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isCurrentUser ? onEdit : onFollowToggle,
            child: Text(isCurrentUser ? "Edit Profile" : "Follow"),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            "$count",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(label),
        ],
      ),
    );
  }
}
