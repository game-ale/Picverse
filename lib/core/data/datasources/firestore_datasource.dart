import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:picverse/features/post/data/models/comment_model.dart';
import 'package:picverse/features/notification/data/models/notification_model.dart';
import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

abstract class FirestoreDatasource {
  // Users
  Future<void> createUser(UserModel user);
  Future<UserModel?> getUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
  Stream<UserModel?> userStream(String userId);
  Future<List<UserModel>> searchUsers(String query);

  // Posts
  Future<String> createPost(Map<String, dynamic> data);
  Future<PostModel?> getPost(String postId);
  Future<void> deletePost(String postId);
  Future<List<PostModel>> getUserPosts(
    String userId, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  });
  Future<List<PostModel>> getFeedPosts(
    List<String> followingIds, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  });

  // Comments
  Future<String> addComment(Map<String, dynamic> data);
  Future<void> deleteComment(String commentId, String postId);
  Future<List<CommentModel>> getComments(
    String postId, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  });

  // Likes
  Future<void> likePost(String postId, String userId);
  Future<void> unlikePost(String postId, String userId);
  Future<bool> isPostLiked(String postId, String userId);

  // Follows
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<bool> isFollowing(String currentUserId, String targetUserId);
  Future<List<String>> getFollowingIds(String userId);
  Future<List<UserModel>> getFollowers(String userId);
  Future<List<UserModel>> getFollowing(String userId);

  // Notifications
  Future<void> createNotification(Map<String, dynamic> data);
  Future<List<NotificationModel>> getNotifications(
    String userId, {
    int limit = 30,
  });
  Future<void> markNotificationRead(String notificationId);
  Future<void> markAllNotificationsRead(String userId);
}
