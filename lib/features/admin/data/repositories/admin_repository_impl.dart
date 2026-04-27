import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/admin/data/models/report_model.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';
import 'package:picverse/features/admin/domain/repositories/admin_repository.dart';
import 'package:picverse/core/services/firestore_service.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirestoreService firestoreService;

  AdminRepositoryImpl({required this.firestoreService});

  @override
  Future<Map<String, int>> getStats() => firestoreService.getAdminStats();

  @override
  Future<List<UserModel>> getAllUsers([int limit = 20]) =>
      firestoreService.getAllUsers(limit: limit);

  @override
  Future<List<PostModel>> getAllPosts([int limit = 20]) =>
      firestoreService.getAllPosts(limit: limit);

  @override
  Future<void> banUser(String userId) => firestoreService.banUser(userId);

  @override
  Future<void> unbanUser(String userId) => firestoreService.unbanUser(userId);

  @override
  Future<void> deletePost(String postId) =>
      firestoreService.adminDeletePost(postId);

  @override
  Future<List<ReportModel>> getPendingReports([int limit = 20]) =>
      firestoreService.getPendingReports(limit: limit);

  @override
  Future<void> resolveReport(String reportId) =>
      firestoreService.updateReportStatus(reportId, 'resolved');

  @override
  Future<void> dismissReport(String reportId) =>
      firestoreService.updateReportStatus(reportId, 'dismissed');

  @override
  Future<void> createReport({
    required String postId,
    required String reportedBy,
    required String reason,
  }) {
    return firestoreService.createReport({
      'postId': postId,
      'reportedBy': reportedBy,
      'reason': reason,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }
}
