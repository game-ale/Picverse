import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:picverse/features/notification/domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.notificationId,
    required super.userId,
    required super.type,
    required super.actorId,
    required super.actorUsername,
    super.postId,
    super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      userId: data['userId'] ?? '',
      type: _parseType(data['type'] ?? ''),
      actorId: data['actorId'] ?? '',
      actorUsername: data['actorUsername'] ?? '',
      postId: data['postId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'actorId': actorId,
      'actorUsername': actorUsername,
      'postId': postId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      default:
        return NotificationType.like;
    }
  }
}
