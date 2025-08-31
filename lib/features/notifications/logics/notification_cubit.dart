import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/Services/notification_services.dart';
import 'package:instagram/features/notifications/data/notification_model.dart';
import 'package:instagram/features/notifications/logics/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService notificationService;

  NotificationCubit({required this.notificationService})
    : super(NotificationInitial());

  Future<void> fetchNotifications(String userId) async {
    try {
      emit(NotificationLoading());
      final notifications = await notificationService.fetchNotifications(
        userId,
      );
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await notificationService.sendNotification(notification);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
