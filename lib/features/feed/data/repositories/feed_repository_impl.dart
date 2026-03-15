import 'package:picverse/features/feed/domain/repositories/feed_repository.dart';
import 'package:picverse/core/services/connectivity_service.dart';
import 'package:picverse/core/services/firestore_service.dart';
import 'package:picverse/core/local/local_cache_service.dart';
import 'package:picverse/features/post/data/models/post_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FirestoreService _firestoreService;
  final LocalCacheService _cacheService;
  final ConnectivityService _connectivityService;

  FeedRepositoryImpl({
    required FirestoreService firestoreService,
    required LocalCacheService cacheService,
    required ConnectivityService connectivityService,
  }) : _firestoreService = firestoreService,
       _cacheService = cacheService,
       _connectivityService = connectivityService;

  @override
  Future<List<String>> getFollowingIds(String userId) {
    return _firestoreService.getFollowingIds(userId);
  }

  @override
  Future<List<PostModel>> getFeedPosts(List<String> followingIds) async {
    if (!_connectivityService.isOnline) {
      return _cacheService.getCachedFeedPosts();
    }

    final posts = await _firestoreService.getFeedPosts(followingIds);
    // Cache in background
    _cacheService.cacheFeedPosts(posts);
    return posts;
  }
}
