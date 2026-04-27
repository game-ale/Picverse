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
  final bool usersHasReachedEnd;
  final bool postsHasReachedEnd;
  final bool reportsHasReachedEnd;
  final bool usersLoadingMore;
  final bool postsLoadingMore;
  final bool reportsLoadingMore;

  const AdminState({
    this.status = AdminStatus.initial,
    this.stats = const {},
    this.users = const [],
    this.posts = const [],
    this.reports = const [],
    this.errorMessage,
    this.usersHasReachedEnd = false,
    this.postsHasReachedEnd = false,
    this.reportsHasReachedEnd = false,
    this.usersLoadingMore = false,
    this.postsLoadingMore = false,
    this.reportsLoadingMore = false,
  });

  AdminState copyWith({
    AdminStatus? status,
    Map<String, int>? stats,
    List<UserModel>? users,
    List<PostModel>? posts,
    List<ReportModel>? reports,
    String? errorMessage,
    bool? usersHasReachedEnd,
    bool? postsHasReachedEnd,
    bool? reportsHasReachedEnd,
    bool? usersLoadingMore,
    bool? postsLoadingMore,
    bool? reportsLoadingMore,
  }) {
    return AdminState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      users: users ?? this.users,
      posts: posts ?? this.posts,
      reports: reports ?? this.reports,
      errorMessage: errorMessage,
      usersHasReachedEnd: usersHasReachedEnd ?? this.usersHasReachedEnd,
      postsHasReachedEnd: postsHasReachedEnd ?? this.postsHasReachedEnd,
      reportsHasReachedEnd: reportsHasReachedEnd ?? this.reportsHasReachedEnd,
      usersLoadingMore: usersLoadingMore ?? this.usersLoadingMore,
      postsLoadingMore: postsLoadingMore ?? this.postsLoadingMore,
      reportsLoadingMore: reportsLoadingMore ?? this.reportsLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stats,
    users,
    posts,
    reports,
    errorMessage,
    usersHasReachedEnd,
    postsHasReachedEnd,
    reportsHasReachedEnd,
    usersLoadingMore,
    postsLoadingMore,
    reportsLoadingMore,
  ];
}
