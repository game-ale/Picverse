import 'package:flutter/material.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/utils/date_formatter.dart';
import 'package:picverse/features/post/data/models/comment_model.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isOwner;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    this.isOwner = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.grey200,
            child: Icon(Icons.person, size: 18, color: AppColors.grey400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.grey900,
                    ),
                    children: [
                      TextSpan(
                        text: '${comment.username} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: comment.text),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.timeAgo(comment.createdAt),
                  style: TextStyle(color: AppColors.grey500, fontSize: 11),
                ),
              ],
            ),
          ),
          if (isOwner)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: AppColors.grey500,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
