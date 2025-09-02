import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Post/Data/post_model.dart';
import 'package:instagram/features/Feed/data/feed_repository.dart';
import 'package:instagram/features/notifications/data/notification_model.dart';
import 'package:instagram/features/notifications/logics/notification_cubit.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final FeedRepository _repository;
  final NotificationCubit notificationCubit;
  StreamSubscription<List<PostModel>>? _feedSubscription;

  FeedCubit(this._repository, this.notificationCubit) : super(FeedInitial());

  void fetchFeed() {
    emit(FeedLoading());
    _feedSubscription?.cancel();

    _feedSubscription = _repository.getFeedPosts().listen(
      (posts) {
        emit(FeedLoaded(posts));
      },
      onError: (error) {
        emit(FeedError(error.toString()));
      },
    );
  }

  Future<void> likePost(
    String postId,
    String userId,
    String postOwnerId,
  ) async {
    try {
      final currentState = state as FeedLoaded?;
      final isLiked =
          currentState?.posts
              .firstWhere((p) => p.id == postId)
              .likes
              .contains(userId) ??
          false;

      await _repository.likePost(postId, userId, isLiked);

      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: userId,
        receiverId: postOwnerId,
        type: 'like',
        postId: postId,
        message: "Someone liked your post",
        createdAt: DateTime.now(),
      );

      notificationCubit.sendNotification(notification);

      if (currentState != null) {
        final updatedPosts = currentState.posts.map((p) {
          if (p.id == postId) {
            final newLikes = List<String>.from(p.likes);
            if (newLikes.contains(userId)) {
              newLikes.remove(userId);
            } else {
              newLikes.add(userId);
            }
            return p.copyWith(likes: newLikes);
          }
          return p;
        }).toList();

        emit(FeedLoaded(updatedPosts));
      }
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> addComment(
    String postId,
    String userId,
    String comment,
    String postOwnerId,
  ) async {
    try {
      final newComment = {
        'userId': userId,
        'username': '',
        'text': comment,
        'userPhotoUrl': '',
      };

      await _repository.addComment(postId, newComment);

      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: userId,
        receiverId: postOwnerId,
        type: 'comment',
        postId: postId,
        message: "Someone commented: $comment",
        createdAt: DateTime.now(),
      );

      notificationCubit.sendNotification(notification);

      if (state is FeedLoaded) {
        final currentState = state as FeedLoaded;
        final updatedPosts = currentState.posts.map((p) {
          if (p.id == postId) {
            final newComments = List<Map<String, dynamic>>.from(p.comments)
              ..add(newComment);
            return p.copyWith(comments: newComments);
          }
          return p;
        }).toList();

        emit(FeedLoaded(updatedPosts));
      }
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _feedSubscription?.cancel();
    return super.close();
  }
}
