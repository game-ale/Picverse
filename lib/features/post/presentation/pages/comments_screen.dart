import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/post/presentation/bloc/post_bloc.dart';
import 'package:picverse/features/post/presentation/bloc/post_event.dart';
import 'package:picverse/features/post/presentation/bloc/post_state.dart';
import 'package:picverse/features/post/presentation/widgets/comment_tile.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(
      PostCommentsLoadRequested(postId: widget.postId),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    context.read<PostBloc>().add(
      PostCommentAdded(postId: widget.postId, text: text),
    );
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUid = context.read<AuthService>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state.status == PostStatus.loading &&
                    state.comments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.comments.isEmpty) {
                  return Center(
                    child: Text(
                      'No comments yet',
                      style: TextStyle(color: AppColors.grey500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return CommentTile(
                      comment: comment,
                      isOwner: comment.userId == currentUid,
                      onDelete: () {
                        context.read<PostBloc>().add(
                          PostCommentDeleted(
                            commentId: comment.commentId,
                            postId: widget.postId,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.cardDarkBorder : AppColors.grey200,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: AppColors.grey500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _onSend(),
                    ),
                  ),
                  TextButton(onPressed: _onSend, child: const Text('Post')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
