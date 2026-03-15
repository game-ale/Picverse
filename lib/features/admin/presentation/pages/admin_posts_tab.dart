import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/utils/date_formatter.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_event.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_state.dart';

class AdminPostsTab extends StatelessWidget {
  const AdminPostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.posts.isEmpty) {
          return const Center(child: Text('No posts found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.posts.length,
          itemBuilder: (context, index) {
            final post = state.posts[index];
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
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.grey200,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.grey200,
                          child: const Icon(Icons.broken_image, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.username,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.grey900,
                            ),
                          ),
                          if (post.caption.isNotEmpty)
                            Text(
                              post.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.grey500,
                                fontSize: 13,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            '${post.likesCount} likes · ${post.commentsCount} comments · ${DateFormatter.timeAgo(post.createdAt)}',
                            style: TextStyle(
                              color: AppColors.grey400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        _showDeleteDialog(context, post.postId);
                      },
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

  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminDeletePost(postId));
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
