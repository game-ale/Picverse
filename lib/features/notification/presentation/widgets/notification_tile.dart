import 'package:flutter/material.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/utils/date_formatter.dart';
import 'package:picverse/features/notification/data/models/notification_model.dart';
import 'package:picverse/features/notification/domain/entities/notification.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.follow:
        return Icons.person_add;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return AppColors.primaryPurple;
      case NotificationType.follow:
        return Colors.green;
    }
  }

  String _messageForType(NotificationType type, String actor) {
    switch (type) {
      case NotificationType.like:
        return '$actor liked your post';
      case NotificationType.comment:
        return '$actor commented on your post';
      case NotificationType.follow:
        return '$actor started following you';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : (isDark
                  ? AppColors.primaryPurple.withAlpha(20)
                  : AppColors.primaryPurple.withAlpha(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              _iconForType(notification.type),
              color: _colorForType(notification.type),
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _messageForType(
                      notification.type,
                      notification.actorUsername,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.timeAgo(notification.createdAt),
                    style: TextStyle(color: AppColors.grey500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
