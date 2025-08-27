import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'post_model.dart';

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
    String imageUrl = post.imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadPostImage(imageFile, post.userId);
    }

    final newPost = post.copyWith(imageUrl: imageUrl);

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
    await _firestore.collection('posts').doc(postId).delete();
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

  List<PostModel> filterPostsByUser(List<PostModel> posts, String userId) {
    return posts.where((post) => post.userId == userId).toList();
  }

  Future<void> likePost(String postId, String userId, bool isLiked) async {
    final postRef = _firestore.collection('posts').doc(postId);
    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<void> addComment(String postId, Map<String, dynamic> comment) async {
    await _firestore.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }
}
