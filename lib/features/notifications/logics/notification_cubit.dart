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
            emit(NotificationLoaded(notifications));
          },
          onError: (e) {
            emit(NotificationError(e.toString()));
          },
        );
  }

  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await notificationRepository.sendNotification(notification);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
