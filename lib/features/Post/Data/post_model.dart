import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String profileName; // 👈 username
  final String userPhotoUrl; // 👈 profile picture
  final String imageUrl;
  final String caption;
  final DateTime createdAt;
  final List<String> likes;
  final List<Map<String, dynamic>> comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.profileName,
    required this.userPhotoUrl,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
  });

  PostModel copyWith({
    String? id,
    String? userId,
    String? profileName,
    String? userPhotoUrl,
    String? imageUrl,
    String? caption,
    DateTime? createdAt,
    List<String>? likes,
    List<Map<String, dynamic>>? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileName: profileName ?? this.profileName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'profileName': profileName,
      'userPhotoUrl': userPhotoUrl,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'comments': comments,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      profileName: map['profileName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
    );
  }
}
