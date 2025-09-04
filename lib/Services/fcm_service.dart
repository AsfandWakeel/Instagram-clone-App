import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FcmService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 🚀 Initialize FCM + Local Notifications
  static Future<void> init() async {
    // Request permission
    await FirebaseMessaging.instance.requestPermission();

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local notifications init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotificationsPlugin.initialize(initSettings);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotificationsPlugin.show(
          0,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    debugPrint("✅ FcmService initialized");
  }

  /// 📱 Generate FCM token and store in Firestore user model
  static Future<void> saveDeviceToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("⚠️ No logged-in user, skipping token save");
        return;
      }

      // Get the FCM token
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint("⚠️ Failed to generate FCM token");
        return;
      }

      // Save to Firestore under the user’s document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {"fcmToken": token},
      );

      debugPrint("✅ FCM token saved for user ${user.uid}");
    } catch (e) {
      debugPrint("❌ Error saving FCM token: $e");
    }
  }

  /// Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    debugPrint("📩 Background message: ${message.notification?.title}");
  }
}
