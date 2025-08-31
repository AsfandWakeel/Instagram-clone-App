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
      await _repository.createPost(post, imageFile: imageFile);
      emit(PostSuccess("✅ Post created successfully"));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> updatePost(PostModel post, {File? imageFile}) async {
    try {
      await _repository.updatePost(post, imageFile: imageFile);
      emit(PostSuccess("✅ Post updated successfully"));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      emit(PostSuccess("🗑️ Post deleted successfully"));
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
