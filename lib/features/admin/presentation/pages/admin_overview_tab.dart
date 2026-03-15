import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_state.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == AdminStatus.error) {
          return Center(
            child: Text(state.errorMessage ?? 'Failed to load dashboard'),
          );
        }

        final totalUsers = state.stats['totalUsers'] ?? 0;
        final totalPosts = state.stats['totalPosts'] ?? 0;
        final pendingReports = state.stats['pendingReports'] ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.grey900,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.people,
                    label: 'Total Users',
                    value: totalUsers.toString(),
                    color: AppColors.info,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.photo_library,
                    label: 'Total Posts',
                    value: totalPosts.toString(),
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.flag,
                    label: 'Pending Reports',
                    value: pendingReports.toString(),
                    color: pendingReports > 0
                        ? AppColors.error
                        : AppColors.grey400,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.grey900,
                ),
              ),
              const SizedBox(height: 12),
              if (state.reports.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No pending reports',
                          style: TextStyle(
                            color: AppColors.grey500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              for (final report in state.reports.take(5))
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.flag, color: Colors.orange),
                    title: Text('Post: ${report.postId}'),
                    subtitle: Text('Reason: ${report.reason.name}'),
                    trailing: Text(
                      report.status.name,
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.cardDarkBorder : AppColors.grey200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.grey900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
