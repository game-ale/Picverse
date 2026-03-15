import 'package:equatable/equatable.dart';

import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/admin/data/models/report_model.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

enum AdminStatus { initial, loading, loaded, error }

class AdminState extends Equatable {
  final AdminStatus status;
  final Map<String, int> stats;
  final List<UserModel> users;
  final List<PostModel> posts;
  final List<ReportModel> reports;
  final String? errorMessage;

  const AdminState({
    this.status = AdminStatus.initial,
    this.stats = const {},
    this.users = const [],
    this.posts = const [],
    this.reports = const [],
    this.errorMessage,
  });

  AdminState copyWith({
    AdminStatus? status,
    Map<String, int>? stats,
    List<UserModel>? users,
    List<PostModel>? posts,
    List<ReportModel>? reports,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      users: users ?? this.users,
      posts: posts ?? this.posts,
      reports: reports ?? this.reports,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, users, posts, reports, errorMessage];
}
