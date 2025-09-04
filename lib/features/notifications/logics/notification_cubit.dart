import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/notifications/data/notification_model.dart';
import 'package:instagram/features/notifications/logics/notification_state.dart';
import 'package:instagram/features/notifications/data/notification_repository.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository notificationRepository;
  StreamSubscription? _subscription;

  NotificationCubit({required this.notificationRepository})
    : super(NotificationInitial());

  void fetchNotifications(String userId) {
    emit(NotificationLoading());

    _subscription?.cancel();
    _subscription = notificationRepository
        .fetchNotifications(userId)
        .listen(
          (notifications) {
            notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            emit(NotificationLoaded(notifications));
          },
          onError: (e) {
            emit(NotificationError(e.toString()));
          },
        );
  }

  Future<void> sendNotification({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String type,
    String? postId,
    String? comment,
    String? senderPhotoUrl,
  }) async {
    try {
      if (senderId == receiverId) {
        return;
      }

      final notificationId = notificationRepository.getNewNotificationId();

      final notification = NotificationModel(
        id: notificationId,
        senderId: senderId,
        receiverId: receiverId,
        type: type,
        postId: postId,
        message: _generateMessage(senderName, type, comment),
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl ?? '',
        comment: comment,
        createdAt: DateTime.now(),
      );

      await notificationRepository.sendNotification(notification);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await notificationRepository.deleteNotification(notificationId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  String _generateMessage(String senderName, String type, String? comment) {
    switch (type) {
      case "like":
        return "$senderName liked your post";
      case "comment":
        return "$senderName commented: ${comment ?? ''}";
      case "follow":
        return "$senderName started following you";
      default:
        return "$senderName sent you a notification";
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
