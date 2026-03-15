import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/utils/date_formatter.dart';
import 'package:picverse/features/admin/domain/entities/report.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_event.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_state.dart';

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No pending reports',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'All reports have been reviewed',
                  style: TextStyle(color: AppColors.grey500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.reports.length,
          itemBuilder: (context, index) {
            final report = state.reports[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: isDark ? AppColors.cardDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isDark
                      ? AppColors.cardDarkBorder
                      : AppColors.grey200,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: _reasonColor(report.reason),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _reasonLabel(report.reason),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.grey900,
                            ),
                          ),
                        ),
                        Text(
                          DateFormatter.timeAgo(report.createdAt),
                          style: TextStyle(
                            color: AppColors.grey400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Post ID: ${report.postId}',
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Reported by: ${report.reportedBy}',
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context
                                  .read<AdminBloc>()
                                  .add(AdminDismissReport(report.reportId));
                            },
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Dismiss'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              context
                                  .read<AdminBloc>()
                                  .add(AdminResolveReport(report.reportId));
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Resolve'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _reasonLabel(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.fakeAccount:
        return 'Fake Account';
      case ReportReason.other:
        return 'Other';
    }
  }

  Color _reasonColor(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return Colors.orange;
      case ReportReason.harassment:
        return Colors.red;
      case ReportReason.violence:
        return Colors.red.shade900;
      case ReportReason.fakeAccount:
        return Colors.amber;
      case ReportReason.other:
        return AppColors.grey500;
    }
  }
}
