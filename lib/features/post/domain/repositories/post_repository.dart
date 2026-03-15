import 'dart:io';

import 'package:picverse/features/post/data/models/comment_model.dart';
import 'package:picverse/features/post/data/models/post_model.dart';

abstract class PostRepository {
  Future<PostModel> createPost({
    required String userId,
    required String username,
    required String userProfileImage,
    required File imageFile,
    required String caption,
  });
  Future<void> deletePost(String postId, String userId);
  Future<PostModel?> getPost(String postId);
  Future<List<PostModel>> getUserPosts(String userId);
  Future<void> likePost(String postId, String userId);
  Future<void> unlikePost(String postId, String userId);
  Future<bool> isPostLiked(String postId, String userId);
  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required String username,
    required String text,
  });
  Future<void> deleteComment(String commentId, String postId);
  Future<List<CommentModel>> getComments(String postId);
  Future<void> syncOfflineQueue();
}
