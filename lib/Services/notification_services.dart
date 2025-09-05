import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/features/notifications/data/notification_model.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String cloudFunctionUrl =
      "https://sendpushhttp-rna7h2m4ta-uc.a.run.app";

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

    final token = receiverDoc.data()?['fcmToken'];
    if (token == null || token.isEmpty) return;

    await _sendPushMessage(
      token,
      "New ${notification.type}",
      notification.message,
      notification.senderPhotoUrl,
      notification.postId,
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

  Future<void> _sendPushMessage(
    String token,
    String title,
    String body, [
    String? imageUrl,
    String? postId,
  ]) async {
    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "title": title,
          "body": body,
          "imageUrl": imageUrl,
          "postId": postId,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint(" Push sent successfully!");
      } else {
        debugPrint("Push failed: ${response.body}");
      }
    } catch (e) {
      debugPrint(" Push error: $e");
    }
  }
}
