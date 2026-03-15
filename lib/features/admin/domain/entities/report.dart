import 'package:equatable/equatable.dart';

enum ReportReason { spam, harassment, violence, fakeAccount, other }

enum ReportStatus { pending, resolved, dismissed }

class ReportEntity extends Equatable {
  final String reportId;
  final String postId;
  final String reportedBy;
  final ReportReason reason;
  final ReportStatus status;
  final DateTime createdAt;

  const ReportEntity({
    required this.reportId,
    required this.postId,
    required this.reportedBy,
    required this.reason,
    this.status = ReportStatus.pending,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [reportId];
}
