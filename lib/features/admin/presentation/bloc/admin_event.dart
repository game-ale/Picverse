import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminLoadDashboard extends AdminEvent {}

class AdminLoadUsers extends AdminEvent {}

class AdminLoadPosts extends AdminEvent {}

class AdminLoadReports extends AdminEvent {}

class AdminBanUser extends AdminEvent {
  final String userId;
  const AdminBanUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AdminUnbanUser extends AdminEvent {
  final String userId;
  const AdminUnbanUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AdminDeletePost extends AdminEvent {
  final String postId;
  const AdminDeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class AdminResolveReport extends AdminEvent {
  final String reportId;
  const AdminResolveReport(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class AdminDismissReport extends AdminEvent {
  final String reportId;
  const AdminDismissReport(this.reportId);

  @override
  List<Object?> get props => [reportId];
}
