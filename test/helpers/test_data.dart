import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/post/data/models/comment_model.dart';
import 'package:picverse/features/notification/data/models/notification_model.dart';
import 'package:picverse/features/notification/domain/entities/notification.dart';
import 'package:picverse/features/admin/data/models/report_model.dart';
import 'package:picverse/features/admin/domain/entities/report.dart';

PostModel createTestPost({
  String postId = 'post1',
  String userId = 'user1',
  String username = 'testuser',
  String imageUrl = 'https://img.test/post.jpg',
  String caption = 'Test caption',
  int likesCount = 5,
  int commentsCount = 2,
}) {
  return PostModel(
    postId: postId,
    userId: userId,
    username: username,
    userProfileImage: 'https://img.test/avatar.jpg',
    imageUrl: imageUrl,
    caption: caption,
    likesCount: likesCount,
    commentsCount: commentsCount,
    createdAt: DateTime(2026, 1, 1),
  );
}

CommentModel createTestComment({
  String commentId = 'comment1',
  String postId = 'post1',
  String userId = 'user1',
  String username = 'testuser',
  String text = 'Test comment',
}) {
  return CommentModel(
    commentId: commentId,
    postId: postId,
    userId: userId,
    username: username,
    text: text,
    createdAt: DateTime(2026, 1, 1),
  );
}

NotificationModel createTestNotification({
  String notificationId = 'notif1',
  String userId = 'user1',
  NotificationType type = NotificationType.like,
  String actorId = 'user2',
  String actorUsername = 'otheruser',
  String? postId = 'post1',
  bool isRead = false,
}) {
  return NotificationModel(
    notificationId: notificationId,
    userId: userId,
    type: type,
    actorId: actorId,
    actorUsername: actorUsername,
    postId: postId,
    isRead: isRead,
    createdAt: DateTime(2026, 1, 1),
  );
}

ReportModel createTestReport({
  String reportId = 'report1',
  String postId = 'post1',
  String reportedBy = 'user1',
  ReportReason reason = ReportReason.spam,
  ReportStatus status = ReportStatus.pending,
}) {
  return ReportModel(
    reportId: reportId,
    postId: postId,
    reportedBy: reportedBy,
    reason: reason,
    status: status,
    createdAt: DateTime(2026, 1, 1),
  );
}
