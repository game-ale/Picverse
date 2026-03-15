import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/post/data/models/post_model.dart';

class PostsGrid extends StatelessWidget {
  final List<PostModel> posts;
  final void Function(PostModel post)? onPostTap;

  const PostsGrid({super.key, required this.posts, this.onPostTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 48,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No posts yet',
                  style: TextStyle(color: AppColors.grey500, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () => onPostTap?.call(post),
          child: CachedNetworkImage(
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: isDark ? AppColors.cardDark : AppColors.grey100,
            ),
            errorWidget: (_, __, ___) => Container(
              color: isDark ? AppColors.cardDark : AppColors.grey100,
              child: const Icon(Icons.broken_image),
            ),
          ),
        );
      }, childCount: posts.length),
    );
  }
}
