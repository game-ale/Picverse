import 'package:picverse/features/notification/domain/repositories/notification_repository.dart';
import 'package:picverse/core/services/firestore_service.dart';
import 'package:picverse/features/notification/data/models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirestoreService _firestoreService;

  NotificationRepositoryImpl({required FirestoreService firestoreService})
    : _firestoreService = firestoreService;

  @override
  Future<List<NotificationModel>> getNotifications(String userId) {
    return _firestoreService.getNotifications(userId);
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String actorId,
    required String actorUsername,
    String? postId,
  }) {
    return _firestoreService.createNotification({
      'userId': userId,
      'type': type,
      'actorId': actorId,
      'actorUsername': actorUsername,
      'postId': postId,
      'isRead': false,
      'createdAt': DateTime.now(),
    });
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _firestoreService.markNotificationRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) {
    return _firestoreService.markAllNotificationsRead(userId);
  }
}
