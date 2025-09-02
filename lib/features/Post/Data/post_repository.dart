import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram/features/Post/Data/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> _uploadPostImage(File imageFile, String userId) async {
    final ref = _storage.ref().child(
      'posts/$userId/${DateTime.now().toIso8601String()}.jpg',
    );
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<PostModel> createPost(PostModel post, {File? imageFile}) async {
    final userDoc = await _firestore.collection('users').doc(post.userId).get();
    final userData = userDoc.data() ?? {};

    final profileName = userData['username'] ?? userData['name'] ?? 'Unknown';
    final userPhotoUrl = userData['profileImage'] ?? userData['photoUrl'] ?? '';

    String imageUrl = post.imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadPostImage(imageFile, post.userId);
    }

    final newPost = post.copyWith(
      imageUrl: imageUrl,
      profileName: profileName,
      userPhotoUrl: userPhotoUrl,
    );

    final docRef = await _firestore.collection('posts').add(newPost.toMap());

    return newPost.copyWith(id: docRef.id);
  }

  Future<void> updatePost(PostModel post, {File? imageFile}) async {
    String imageUrl = post.imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadPostImage(imageFile, post.userId);
    }
    final updatedPost = post.copyWith(imageUrl: imageUrl);
    await _firestore
        .collection('posts')
        .doc(post.id)
        .update(updatedPost.toMap());
  }

  Future<void> deletePost(String postId) async {
    final docRef = _firestore.collection('posts').doc(postId);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      final imageUrl = data['imageUrl'] ?? '';
      if (imageUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (_) {}
      }
      await docRef.delete();
    }
  }

  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PostModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> likePost(String postId, String userId) async {
    final docRef = _firestore.collection('posts').doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final likes = List<String>.from(doc['likes'] ?? []);
    if (likes.contains(userId)) {
      await docRef.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<void> addComment(String postId, String userId, String comment) async {
    final docRef = _firestore.collection('posts').doc(postId);

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};

    final commentData = {
      'userId': userId,
      'username': userData['username'] ?? userData['name'] ?? 'Unknown',
      'userPhotoUrl': userData['profileImage'] ?? userData['photoUrl'] ?? '',
      'comment': comment,
      'likedUsers': <String>[],
      'createdAt': Timestamp.now(),
    };

    await docRef.update({
      'comments': FieldValue.arrayUnion([commentData]),
    });
  }

  Future<void> toggleCommentLike(
    String postId,
    int commentIndex,
    String userId,
  ) async {
    final docRef = _firestore.collection('posts').doc(postId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data()!;
    final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

    if (commentIndex < 0 || commentIndex >= comments.length) return;

    final comment = comments[commentIndex];
    final likedUsers = List<String>.from(comment['likedUsers'] ?? []);

    if (likedUsers.contains(userId)) {
      likedUsers.remove(userId);
    } else {
      likedUsers.add(userId);
    }

    comments[commentIndex] = {...comment, 'likedUsers': likedUsers};

    await docRef.update({'comments': comments});
  }
}
