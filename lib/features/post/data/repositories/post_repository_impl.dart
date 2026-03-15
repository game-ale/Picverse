import 'dart:io';

import 'package:uuid/uuid.dart';

import 'package:picverse/features/post/domain/repositories/post_repository.dart';
import 'package:picverse/core/services/connectivity_service.dart';
import 'package:picverse/core/services/firestore_service.dart';
import 'package:picverse/core/services/storage_service.dart';
import 'package:picverse/core/local/local_cache_service.dart';
import 'package:picverse/core/local/offline_queue_service.dart';
import 'package:picverse/features/post/data/models/comment_model.dart';
import 'package:picverse/features/post/data/models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final LocalCacheService _cacheService;
  final OfflineQueueService _offlineQueue;
  final ConnectivityService _connectivityService;
  final _uuid = const Uuid();

  PostRepositoryImpl({
    required FirestoreService firestoreService,
    required StorageService storageService,
    required LocalCacheService cacheService,
    required OfflineQueueService offlineQueue,
    required ConnectivityService connectivityService,
  }) : _firestoreService = firestoreService,
       _storageService = storageService,
       _cacheService = cacheService,
       _offlineQueue = offlineQueue,
       _connectivityService = connectivityService;

  @override
  Future<PostModel> createPost({
    required String userId,
    required String username,
    required String userProfileImage,
    required File imageFile,
    required String caption,
  }) async {
    final fileName = '${_uuid.v4()}.jpg';
    final imageUrl = await _storageService.uploadPostImage(
      userId,
      fileName,
      imageFile,
    );

    final post = PostModel(
      postId: '',
      userId: userId,
      username: username,
      userProfileImage: userProfileImage,
      imageUrl: imageUrl,
      caption: caption,
      createdAt: DateTime.now(),
    );

    final postId = await _firestoreService.createPost(post.toFirestore());
    return PostModel(
      postId: postId,
      userId: userId,
      username: username,
      userProfileImage: userProfileImage,
      imageUrl: imageUrl,
      caption: caption,
      createdAt: post.createdAt,
    );
  }

  @override
  Future<void> deletePost(String postId, String userId) async {
    await _firestoreService.deletePost(postId);
  }

  @override
  Future<PostModel?> getPost(String postId) {
    return _firestoreService.getPost(postId);
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId) {
    return _firestoreService.getUserPosts(userId);
  }

  // ─── Likes ───

  @override
  Future<void> likePost(String postId, String userId) async {
    if (_connectivityService.isOnline) {
      await _firestoreService.likePost(postId, userId);
    } else {
      await _offlineQueue.enqueue(
        action: 'like',
        postId: postId,
        userId: userId,
      );
    }
    await _cacheService.addLikedPostId(postId);
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    if (_connectivityService.isOnline) {
      await _firestoreService.unlikePost(postId, userId);
    } else {
      await _offlineQueue.enqueue(
        action: 'unlike',
        postId: postId,
        userId: userId,
      );
    }
    await _cacheService.removeLikedPostId(postId);
  }

  @override
  Future<bool> isPostLiked(String postId, String userId) async {
    if (!_connectivityService.isOnline) {
      final cached = await _cacheService.getCachedLikedPostIds();
      return cached.contains(postId);
    }
    return _firestoreService.isPostLiked(postId, userId);
  }

  /// Replays queued like/unlike operations after connectivity is restored.
  @override
  Future<void> syncOfflineQueue() async {
    final items = await _offlineQueue.drain();
    for (final item in items) {
      final action = item['action'] as String;
      final postId = item['postId'] as String;
      final userId = item['userId'] as String;
      if (action == 'like') {
        await _firestoreService.likePost(postId, userId);
      } else {
        await _firestoreService.unlikePost(postId, userId);
      }
    }
  }

  // ─── Comments ───

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required String username,
    required String text,
  }) async {
    final data = CommentModel(
      commentId: '',
      postId: postId,
      userId: userId,
      username: username,
      text: text,
      createdAt: DateTime.now(),
    );
    final commentId = await _firestoreService.addComment(data.toFirestore());
    return CommentModel(
      commentId: commentId,
      postId: postId,
      userId: userId,
      username: username,
      text: text,
      createdAt: data.createdAt,
    );
  }

  @override
  Future<void> deleteComment(String commentId, String postId) {
    return _firestoreService.deleteComment(commentId, postId);
  }

  @override
  Future<List<CommentModel>> getComments(String postId) {
    return _firestoreService.getComments(postId);
  }
}
