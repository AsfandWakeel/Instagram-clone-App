class ProfileModel {
  final String uid;
  final String username;
  final String bio;
  final String photoUrl;
  final List<String> followers;
  final List<String> following;
  final List<String> posts;
  final bool isPrivate;

  const ProfileModel({
    required this.uid,
    required this.username,
    required this.bio,
    required this.photoUrl,
    this.followers = const [],
    this.following = const [],
    this.posts = const [],
    this.isPrivate = false,
  });

  int get followersCount => followers.length;
  int get followingCount => following.length;
  int get postsCount => posts.length;

  ProfileModel copyWith({
    String? username,
    String? bio,
    String? photoUrl,
    List<String>? followers,
    List<String>? following,
    List<String>? posts,
    bool? isPrivate,
  }) {
    return ProfileModel(
      uid: uid,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: posts ?? this.posts,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  factory ProfileModel.fromMap(
    Map<String, dynamic> map, {
    required String uid,
  }) {
    return ProfileModel(
      uid: uid,
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      posts: List<String>.from(map['posts'] ?? []),
      isPrivate: map['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'bio': bio,
      'photoUrl': photoUrl,
      'followers': followers,
      'following': following,
      'posts': posts,
      'isPrivate': isPrivate,
    };
  }
}
