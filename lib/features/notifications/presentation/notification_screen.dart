import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/notifications/data/notification_model.dart';
import 'package:instagram/features/notifications/logics/notification_cubit.dart';
import 'package:instagram/features/notifications/logics/notification_state.dart';

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
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final NotificationModel notification =
                    state.notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notification.message),
                  subtitle: Text(notification.type),
                  trailing: Text(
                    "${notification.createdAt.hour}:${notification.createdAt.minute}",
                    style: const TextStyle(fontSize: 12),
                  ),
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
}
