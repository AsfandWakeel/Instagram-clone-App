import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String type;
  final String? postId;
  final String message;
  final String senderName;
  final String senderPhotoUrl;
  final String? comment;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.postId,
    required this.message,
    required this.senderName,
    required this.senderPhotoUrl,
    this.comment,
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
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      receiverId: map['receiverId']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      postId: map['postId']?.toString(),
      message: map['message']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? '',
      senderPhotoUrl: map['senderPhotoUrl']?.toString() ?? '',
      comment: map['comment']?.toString(),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
                DateTime.now(),
    );
  }

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap(data);
  }
}
