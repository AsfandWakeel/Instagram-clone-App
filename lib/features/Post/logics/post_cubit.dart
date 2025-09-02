import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/Data/post_repository.dart';
import 'package:instagram/features/Post/logics/post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _repository;
  StreamSubscription<List<PostModel>>? _subscription;

  PostCubit(this._repository) : super(PostInitial());

  void fetchPosts() {
    emit(PostLoading());
    _subscription?.cancel();

    _subscription = _repository.getPosts().listen(
      (posts) => emit(PostLoaded(posts)),
      onError: (error) => emit(PostError(error.toString())),
    );
  }

  Future<void> createPost(PostModel post, {File? imageFile}) async {
    try {
      final newPost = await _repository.createPost(post, imageFile: imageFile);

      if (state is PostLoaded) {
        final currentPosts = (state as PostLoaded).posts;
        emit(PostLoaded([newPost, ...currentPosts]));
      } else {
        emit(PostSuccess("Post created successfully"));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> updatePost(PostModel post, {File? imageFile}) async {
    try {
      await _repository.updatePost(post, imageFile: imageFile);

      if (state is PostLoaded) {
        final currentPosts = (state as PostLoaded).posts.map((p) {
          return p.id == post.id ? post : p;
        }).toList();
        emit(PostLoaded(currentPosts));
      } else {
        emit(PostSuccess("Post updated successfully"));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);

      if (state is PostLoaded) {
        final currentPosts = (state as PostLoaded).posts;
        final updatedPosts = currentPosts.where((p) => p.id != postId).toList();
        emit(PostLoaded(updatedPosts));
      } else {
        emit(PostSuccess("Post deleted successfully"));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _repository.likePost(postId, userId);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> addComment(String postId, String userId, String comment) async {
    try {
      await _repository.addComment(postId, userId, comment);

      if (state is PostLoaded) {
        final currentPosts = (state as PostLoaded).posts;
        emit(PostLoaded(List<PostModel>.from(currentPosts)));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> toggleCommentLike(
    String postId,
    int commentIndex,
    String userId,
  ) async {
    try {
      await _repository.toggleCommentLike(postId, commentIndex, userId);

      if (state is PostLoaded) {
        final currentPosts = (state as PostLoaded).posts.map((p) => p).toList();
        emit(PostLoaded(currentPosts));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  List<PostModel> getUserPosts(List<PostModel> posts, String userId) {
    return posts.where((post) => post.userId == userId).toList();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
