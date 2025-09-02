import 'package:instagram/features/notifications/data/notification_model.dart';
import 'package:instagram/services/notification_services.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository(this._notificationService);

  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await _notificationService.sendNotification(notification);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<NotificationModel>> fetchNotifications(String userId) {
    return _notificationService.fetchNotifications(userId);
  }
}
