import 'package:flutter/material.dart';
import 'package:instagram/features/Profile/Data/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel user;
  final bool isCurrentUser;
  final VoidCallback? onFollowToggle;
  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.user,
    this.isCurrentUser = false,
    this.onFollowToggle,
    this.onEdit,
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
            _buildStat("Posts", user.postsCount.toString()),
            _buildStat("Followers", user.followersCount.toString()),
            _buildStat("Following", user.followingCount.toString()),
          ],
        ),
        const SizedBox(height: 12),
        isCurrentUser
            ? ElevatedButton(
                onPressed: onEdit,
                child: const Text("Edit Profile"),
              )
            : ElevatedButton(
                onPressed: onFollowToggle,
                child: Text(
                  user.followers.contains(user.uid) ? "Unfollow" : "Follow",
                ),
              ),
      ],
    );
  }

  Widget _buildStat(String label, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(label),
        ],
      ),
    );
  }
}
