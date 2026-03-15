import 'package:equatable/equatable.dart';

enum NotificationType { like, comment, follow }

class NotificationEntity extends Equatable {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String actorId;
  final String actorUsername;
  final String? postId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.actorId,
    required this.actorUsername,
    this.postId,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [notificationId];
}
