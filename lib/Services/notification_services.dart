import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/features/notifications/data/notification_model.dart';

class NotificationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String serverKey =
      "BAiPQ8ezWhwjntyM4qys6D0sweDLWF1BA1MpevQ0B-ozzLHWqvfHm9yG8feb0xde4MXdGld-e2yonNmLBgcdh60";

  Future<void> sendNotification(NotificationModel notification) async {
    await firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());

    final receiverDoc = await firestore
        .collection('users')
        .doc(notification.receiverId)
        .get();

    if (!receiverDoc.exists) return;

    final token = receiverDoc['fcmToken'];
    if (token == null) return;

    await _sendPushMessage(
      token,
      "New ${notification.type}",
      notification.message,
    );
  }

  Stream<List<NotificationModel>> fetchNotifications(String userId) {
    return firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromDoc(doc))
              .toList(),
        );
  }

  Future<void> _sendPushMessage(String token, String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey",
        },
        body: jsonEncode({
          "to": token,
          "notification": {"title": title, "body": body},
          "priority": "high",
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("Failed to send push notification: ${response.body}");
      } else {
        debugPrint("Push notification sent!");
      }
    } catch (e) {
      debugPrint("Error sending push notification: $e");
    }
  }
}
