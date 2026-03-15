import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/notification/domain/entities/notification.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_event.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_state.dart';
import 'package:picverse/features/notification/presentation/widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(NotificationLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationBloc>().add(
              NotificationMarkAllReadRequested(),
            ),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(color: AppColors.grey500, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = state.notifications[index];
              return NotificationTile(
                notification: n,
                onTap: () {
                  if (!n.isRead) {
                    context.read<NotificationBloc>().add(
                      NotificationMarkReadRequested(
                        notificationId: n.notificationId,
                      ),
                    );
                  }
                  // Navigate based on type
                  if (n.type == NotificationType.follow) {
                    context.push('/profile/${n.actorId}');
                  } else if (n.postId != null && n.postId!.isNotEmpty) {
                    context.push('/comments/${n.postId}');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
