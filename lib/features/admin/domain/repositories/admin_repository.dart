import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/admin/data/models/report_model.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

abstract class AdminRepository {
  Future<Map<String, int>> getStats();
  Future<List<UserModel>> getAllUsers();
  Future<List<PostModel>> getAllPosts();
  Future<void> banUser(String userId);
  Future<void> unbanUser(String userId);
  Future<void> deletePost(String postId);
  Future<List<ReportModel>> getPendingReports();
  Future<void> resolveReport(String reportId);
  Future<void> dismissReport(String reportId);
  Future<void> createReport({
    required String postId,
    required String reportedBy,
    required String reason,
  });
}
