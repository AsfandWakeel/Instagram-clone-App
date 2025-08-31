import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/notifications/data/notification_model.dart';

class NotificationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendNotification(NotificationModel notification) async {
    await firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final snapshot = await firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => NotificationModel.fromDoc(doc)).toList();
  }
}
