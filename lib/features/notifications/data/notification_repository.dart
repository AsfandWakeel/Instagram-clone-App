import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/notifications/data/notification_model.dart';
import 'package:instagram/services/notification_services.dart';

class NotificationRepository {
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  String getNewNotificationId() {
    return _firestore.collection('notifications').doc().id;
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
