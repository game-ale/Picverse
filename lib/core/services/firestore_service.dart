import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:picverse/core/constants/app_constants.dart';
import 'package:picverse/features/post/data/models/comment_model.dart';
import 'package:picverse/features/notification/data/models/notification_model.dart';
import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/admin/data/models/report_model.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Collection Refs ───
  CollectionReference get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);
  CollectionReference get _postsRef =>
      _firestore.collection(AppConstants.postsCollection);
  CollectionReference get _commentsRef =>
      _firestore.collection(AppConstants.commentsCollection);
  CollectionReference get _likesRef =>
      _firestore.collection(AppConstants.likesCollection);
  CollectionReference get _followsRef =>
      _firestore.collection(AppConstants.followsCollection);
  CollectionReference get _notificationsRef =>
      _firestore.collection(AppConstants.notificationsCollection);

  // ─── Users ───

  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.userId).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _usersRef.doc(userId).update(data);
  }

  Stream<UserModel?> userStream(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final snap = await _usersRef
        .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('username', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
        .limit(20)
        .get();
    return snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
  }

  // ─── Posts ───

  Future<String> createPost(Map<String, dynamic> data) async {
    final doc = await _postsRef.add(data);
    return doc.id;
  }

  Future<PostModel?> getPost(String postId) async {
    final doc = await _postsRef.doc(postId).get();
    if (!doc.exists) return null;
    return PostModel.fromFirestore(doc);
  }

  Future<void> deletePost(String postId) async {
    await _postsRef.doc(postId).delete();
  }

  Future<List<PostModel>> getUserPosts(
    String userId, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query query = _postsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    final snap = await query.get();
    return snap.docs.map((d) => PostModel.fromFirestore(d)).toList();
  }

  Future<List<PostModel>> getFeedPosts(
    List<String> followingIds, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    if (followingIds.isEmpty) return [];
    // Firestore 'whereIn' supports max 30 values
    final batches = <List<String>>[];
    for (var i = 0; i < followingIds.length; i += 30) {
      batches.add(
        followingIds.sublist(
          i,
          i + 30 > followingIds.length ? followingIds.length : i + 30,
        ),
      );
    }
    final results = <PostModel>[];
    for (final batch in batches) {
      Query query = _postsRef
          .where('userId', whereIn: batch)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (lastDoc != null) query = query.startAfterDocument(lastDoc);
      final snap = await query.get();
      results.addAll(snap.docs.map((d) => PostModel.fromFirestore(d)));
    }
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results.take(limit).toList();
  }

  // ─── Comments ───

  Future<String> addComment(Map<String, dynamic> data) async {
    final doc = await _commentsRef.add(data);
    // Increment comment count
    await _postsRef.doc(data['postId']).update({
      'commentsCount': FieldValue.increment(1),
    });
    return doc.id;
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await _commentsRef.doc(commentId).delete();
    await _postsRef.doc(postId).update({
      'commentsCount': FieldValue.increment(-1),
    });
  }

  Future<List<CommentModel>> getComments(
    String postId, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query query = _commentsRef
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    final snap = await query.get();
    return snap.docs.map((d) => CommentModel.fromFirestore(d)).toList();
  }

  // ─── Likes ───

  Future<void> likePost(String postId, String userId) async {
    final docId = '${userId}_$postId';
    await _likesRef.doc(docId).set({
      'postId': postId,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _postsRef.doc(postId).update({'likesCount': FieldValue.increment(1)});
  }

  Future<void> unlikePost(String postId, String userId) async {
    final docId = '${userId}_$postId';
    await _likesRef.doc(docId).delete();
    await _postsRef.doc(postId).update({
      'likesCount': FieldValue.increment(-1),
    });
  }

  Future<bool> isPostLiked(String postId, String userId) async {
    final docId = '${userId}_$postId';
    final doc = await _likesRef.doc(docId).get();
    return doc.exists;
  }

  // ─── Follows ───

  Future<void> followUser(String currentUserId, String targetUserId) async {
    final docId = '${currentUserId}_$targetUserId';
    await _followsRef.doc(docId).set({
      'followerId': currentUserId,
      'followingId': targetUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _usersRef.doc(currentUserId).update({
      'followingCount': FieldValue.increment(1),
    });
    await _usersRef.doc(targetUserId).update({
      'followersCount': FieldValue.increment(1),
    });
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final docId = '${currentUserId}_$targetUserId';
    await _followsRef.doc(docId).delete();
    await _usersRef.doc(currentUserId).update({
      'followingCount': FieldValue.increment(-1),
    });
    await _usersRef.doc(targetUserId).update({
      'followersCount': FieldValue.increment(-1),
    });
  }

  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final docId = '${currentUserId}_$targetUserId';
    final doc = await _followsRef.doc(docId).get();
    return doc.exists;
  }

  Future<List<String>> getFollowingIds(String userId) async {
    final snap = await _followsRef.where('followerId', isEqualTo: userId).get();
    return snap.docs.map((d) => d['followingId'] as String).toList();
  }

  Future<List<UserModel>> getFollowers(String userId) async {
    final snap = await _followsRef
        .where('followingId', isEqualTo: userId)
        .get();
    final ids = snap.docs.map((d) => d['followerId'] as String).toList();
    if (ids.isEmpty) return [];
    final users = <UserModel>[];
    for (final id in ids) {
      final u = await getUser(id);
      if (u != null) users.add(u);
    }
    return users;
  }

  Future<List<UserModel>> getFollowing(String userId) async {
    final snap = await _followsRef.where('followerId', isEqualTo: userId).get();
    final ids = snap.docs.map((d) => d['followingId'] as String).toList();
    if (ids.isEmpty) return [];
    final users = <UserModel>[];
    for (final id in ids) {
      final u = await getUser(id);
      if (u != null) users.add(u);
    }
    return users;
  }

  // ─── Notifications ───

  Future<void> createNotification(Map<String, dynamic> data) async {
    await _notificationsRef.add(data);
  }

  Future<List<NotificationModel>> getNotifications(
    String userId, {
    int limit = 30,
  }) async {
    final snap = await _notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => NotificationModel.fromFirestore(d)).toList();
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final snap = await _notificationsRef
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ─── Admin / Reports ───

  CollectionReference get _reportsRef =>
      _firestore.collection(AppConstants.reportsCollection);

  Future<List<UserModel>> getAllUsers({int limit = 50}) async {
    final snap = await _usersRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
  }

  Future<List<PostModel>> getAllPosts({int limit = 50}) async {
    final snap = await _postsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => PostModel.fromFirestore(d)).toList();
  }

  Future<void> banUser(String userId) async {
    await _usersRef.doc(userId).update({'status': 'banned'});
  }

  Future<void> unbanUser(String userId) async {
    await _usersRef.doc(userId).update({'status': 'active'});
  }

  Future<void> adminDeletePost(String postId) async {
    await _postsRef.doc(postId).delete();
    // Remove related likes
    final likes = await _likesRef
        .where('postId', isEqualTo: postId)
        .get();
    final batch = _firestore.batch();
    for (final doc in likes.docs) {
      batch.delete(doc.reference);
    }
    // Remove related comments
    final comments = await _commentsRef
        .where('postId', isEqualTo: postId)
        .get();
    for (final doc in comments.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<String> createReport(Map<String, dynamic> data) async {
    final doc = await _reportsRef.add(data);
    return doc.id;
  }

  Future<List<ReportModel>> getReports({int limit = 50}) async {
    final snap = await _reportsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => ReportModel.fromFirestore(d)).toList();
  }

  Future<List<ReportModel>> getPendingReports({int limit = 50}) async {
    final snap = await _reportsRef
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => ReportModel.fromFirestore(d)).toList();
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    await _reportsRef.doc(reportId).update({'status': status});
  }

  Future<Map<String, int>> getAdminStats() async {
    final usersSnap = await _usersRef.count().get();
    final postsSnap = await _postsRef.count().get();
    final reportsSnap = await _reportsRef
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return {
      'totalUsers': usersSnap.count ?? 0,
      'totalPosts': postsSnap.count ?? 0,
      'pendingReports': reportsSnap.count ?? 0,
    };
  }
}
