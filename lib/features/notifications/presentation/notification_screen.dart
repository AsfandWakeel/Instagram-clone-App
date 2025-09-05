import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:instagram/features/notifications/data/notification_model.dart';
import 'package:instagram/features/notifications/logics/notification_cubit.dart';
import 'package:instagram/features/notifications/logics/notification_state.dart';
import 'package:instagram/features/Profile/Presentation/profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String currentUserId;

  const NotificationsScreen({super.key, required this.currentUserId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().fetchNotifications(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text("No notifications yet."));
            }

            final notifications = state.notifications.reversed.toList();

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final NotificationModel notification = notifications[index];

                final senderName = notification.senderName.isNotEmpty
                    ? notification.senderName
                    : "Someone";

                String displayMessage;
                if (notification.type == "like") {
                  displayMessage = "$senderName liked your post";
                } else if (notification.type == "comment") {
                  displayMessage =
                      "$senderName commented: ${notification.comment ?? ''}";
                } else if (notification.type == "follow") {
                  displayMessage = "$senderName started following you";
                } else {
                  displayMessage = notification.message;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: notification.senderPhotoUrl.isNotEmpty
                        ? NetworkImage(notification.senderPhotoUrl)
                        : null,
                    child: notification.senderPhotoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    displayMessage,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    if (notification.type == "follow") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                            uid: notification.senderId,
                            currentUserId: widget.currentUserId,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Post preview disabled in this version",
                          ),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    context.read<NotificationCubit>().deleteNotification(
                      notification.id,
                    );
                  },
                );
              },
            );
          } else if (state is NotificationError) {
            return Center(child: Text("Error: ${state.error}"));
          }
          return const SizedBox();
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return DateFormat('dd MMM, hh:mm a').format(time);
    }
  }
}
