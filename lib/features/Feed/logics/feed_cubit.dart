import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Post/Data/post_repository.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final PostRepository _repository;
  StreamSubscription<List<PostModel>>? _feedSubscription;

  FeedCubit(this._repository) : super(FeedInitial());

  void fetchFeed() {
    emit(FeedLoading());

    _feedSubscription?.cancel();

    _feedSubscription = _repository.getPosts().listen(
      (posts) {
        emit(FeedLoaded(posts));
      },
      onError: (error) {
        emit(FeedError(error.toString()));
      },
    );
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _repository.likePost(postId, userId);
    } catch (e) {
      // Optionally log error
    }
  }

  Future<void> addComment(String postId, String userId, String comment) async {
    try {
      await _repository.addComment(postId, userId, comment);
    } catch (e) {
      // Optionally log error
    }
  }

  @override
  Future<void> close() {
    _feedSubscription?.cancel();
    return super.close();
  }
}
