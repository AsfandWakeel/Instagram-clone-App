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
    // 🔹 Step 1: Get user data from users collection
    final userDoc = await _firestore.collection('users').doc(post.userId).get();

    final userData = userDoc.data() ?? {};

    // 🔹 Step 2: Set profile info from user document
    final profileName = userData['username'] ?? 'Unknown';
    final userPhotoUrl = userData['profileImage'] ?? '';

    // 🔹 Step 3: Upload image if provided
    String imageUrl = post.imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadPostImage(imageFile, post.userId);
    }

    // 🔹 Step 4: Create final PostModel with user info
    final newPost = post.copyWith(
      imageUrl: imageUrl,
      profileName: profileName,
      userPhotoUrl: userPhotoUrl,
    );

    // 🔹 Step 5: Save to Firestore
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

    // fetch username + photo for comments also (like insta)
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};

    final commentData = {
      'userId': userId,
      'username': userData['username'] ?? 'Unknown',
      'userPhotoUrl': userData['profileImage'] ?? '',
      'comment': comment,
      'createdAt': Timestamp.now(),
    };

    await docRef.update({
      'comments': FieldValue.arrayUnion([commentData]),
    });
  }
}
