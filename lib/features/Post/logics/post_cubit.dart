import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/Data/post_repository.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _repository;
  PostCubit(this._repository) : super(PostInitial());

  void fetchPosts() {
    try {
      emit(PostLoading());

      _repository.getPosts().listen(
        (posts) {
          emit(PostLoaded(posts));
        },
        onError: (e) {
          emit(PostError(e.toString()));
        },
      );
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> createPost(PostModel post, {File? imageFile}) async {
    try {
      await _repository.createPost(post, imageFile: imageFile);
      // stream auto-update karega, fetchPosts dobara call karne ki zarurat nahi
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> updatePost(PostModel post, {File? imageFile}) async {
    try {
      await _repository.updatePost(post, imageFile: imageFile);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> likePost(String postId, String userId, bool isLiked) async {
    try {
      await _repository.likePost(postId, userId, isLiked);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> addComment(String postId, Map<String, dynamic> comment) async {
    try {
      await _repository.addComment(postId, comment);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  List<PostModel> getUserPosts(String userId) {
    if (state is PostLoaded) {
      return _repository.filterPostsByUser((state as PostLoaded).posts, userId);
    }
    return [];
  }
}
