import 'package:picverse/features/notification/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);
  Stream<List<NotificationModel>> watchNotifications(String userId);
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String actorId,
    required String actorUsername,
    String? postId,
  });
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
}
