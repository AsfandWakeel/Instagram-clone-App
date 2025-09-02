import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String type;
  final String? postId;
  final String message;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.postId,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type,
      'postId': postId,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: data['type'] ?? '',
      postId: data['postId'],
      message: data['message'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
    );
  }
}
