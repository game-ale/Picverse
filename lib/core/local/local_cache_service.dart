import 'package:hive_flutter/hive_flutter.dart';

import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';
import 'package:picverse/core/local/hive_constants.dart';

/// Manages local Hive cache for feed posts, user profiles, and liked post IDs.
class LocalCacheService {
  // ─── Feed Cache ───

  Future<void> cacheFeedPosts(List<PostModel> posts) async {
    final box = await Hive.openBox<PostModel>(HiveConstants.feedBox);
    await box.clear();
    for (final post in posts) {
      await box.put(post.postId, post);
    }
  }

  Future<List<PostModel>> getCachedFeedPosts() async {
    final box = await Hive.openBox<PostModel>(HiveConstants.feedBox);
    final posts = box.values.toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  // ─── Profile Cache ───

  Future<void> cacheProfile(UserModel user) async {
    final box = await Hive.openBox<UserModel>(HiveConstants.profileBox);
    await box.put(user.userId, user);
  }

  Future<UserModel?> getCachedProfile(String userId) async {
    final box = await Hive.openBox<UserModel>(HiveConstants.profileBox);
    return box.get(userId);
  }

  // ─── Liked Posts Cache ───

  Future<void> cacheLikedPostIds(Set<String> ids) async {
    final box = await Hive.openBox<String>(HiveConstants.likedPostsBox);
    await box.clear();
    for (final id in ids) {
      await box.put(id, id);
    }
  }

  Future<Set<String>> getCachedLikedPostIds() async {
    final box = await Hive.openBox<String>(HiveConstants.likedPostsBox);
    return box.values.toSet();
  }

  Future<void> addLikedPostId(String postId) async {
    final box = await Hive.openBox<String>(HiveConstants.likedPostsBox);
    await box.put(postId, postId);
  }

  Future<void> removeLikedPostId(String postId) async {
    final box = await Hive.openBox<String>(HiveConstants.likedPostsBox);
    await box.delete(postId);
  }

  // ─── Clear All ───

  Future<void> clearAll() async {
    await Hive.deleteBoxFromDisk(HiveConstants.feedBox);
    await Hive.deleteBoxFromDisk(HiveConstants.profileBox);
    await Hive.deleteBoxFromDisk(HiveConstants.likedPostsBox);
    await Hive.deleteBoxFromDisk(HiveConstants.offlineQueueBox);
  }
}
