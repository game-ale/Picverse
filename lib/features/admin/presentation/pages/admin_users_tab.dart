import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_event.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_state.dart';

class AdminUsersTab extends StatelessWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.users.length +
              (state.usersLoadingMore ? 1 : 0) +
              (state.usersHasReachedEnd ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= state.users.length) {
              if (state.usersLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () => context.read<AdminBloc>().add(
                      AdminLoadMoreUsers(),
                    ),
                    child: const Text('Load more users'),
                  ),
                ),
              );
            }
            final user = state.users[index];
            return Column(
              children: [
                _UserTile(
                  username: user.username,
                  email: user.email,
                  followers: user.followersCount,
                  posts: user.postsCount,
                  role: user.role,
                  status: user.status,
                  onBan: () {
                    context.read<AdminBloc>().add(AdminBanUser(user.userId));
                  },
                  onUnban: () {
                    context.read<AdminBloc>().add(AdminUnbanUser(user.userId));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final String username;
  final String email;
  final int followers;
  final int posts;
  final String role;
  final String status;
  final VoidCallback onBan;
  final VoidCallback onUnban;

  const _UserTile({
    required this.username,
    required this.email,
    required this.followers,
    required this.posts,
    required this.role,
    required this.status,
    required this.onBan,
    required this.onUnban,
  });

  bool get isBanned => status == 'banned';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark ? AppColors.cardDarkBorder : AppColors.grey200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.grey900,
                        ),
                      ),
                      if (role == 'admin')
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (isBanned)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Banned',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$followers followers · $posts posts',
                    style: TextStyle(
                      color: AppColors.grey400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (role != 'admin')
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'ban') onBan();
                  if (value == 'unban') onUnban();
                },
                itemBuilder: (_) => [
                  if (!isBanned)
                    const PopupMenuItem(value: 'ban', child: Text('Ban User'))
                  else
                    const PopupMenuItem(
                      value: 'unban',
                      child: Text('Unban User'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
