import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:picverse/features/admin/domain/entities/report.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.reportId,
    required super.postId,
    required super.reportedBy,
    required super.reason,
    super.status,
    required super.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      reportId: doc.id,
      postId: data['postId'] ?? '',
      reportedBy: data['reportedBy'] ?? '',
      reason: _parseReason(data['reason'] ?? ''),
      status: _parseStatus(data['status'] ?? ''),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'reportedBy': reportedBy,
      'reason': reason.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static ReportReason _parseReason(String value) {
    return ReportReason.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportReason.other,
    );
  }

  static ReportStatus _parseStatus(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.pending,
    );
  }
}
