import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/constants/app_constants.dart';
import 'package:picverse/core/local/local_cache_service.dart';
import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/feed/domain/repositories/feed_repository.dart';
import 'package:picverse/features/post/domain/repositories/post_repository.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/core/services/connectivity_service.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_event.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _feedRepository;
  final PostRepository _postRepository;
  final AuthService _authService;
  final ConnectivityService _connectivityService;
  final LocalCacheService _cacheService;
  StreamSubscription<bool>? _connectivitySub;

  FeedBloc({
    required FeedRepository feedRepository,
    required PostRepository postRepository,
    required AuthService authService,
    required ConnectivityService connectivityService,
    required LocalCacheService cacheService,
  }) : _feedRepository = feedRepository,
       _postRepository = postRepository,
       _authService = authService,
       _connectivityService = connectivityService,
       _cacheService = cacheService,
       super(const FeedState()) {
    on<FeedLoadRequested>(_onLoad);
    on<FeedRefreshRequested>(_onRefresh);
    on<FeedLoadMoreRequested>(_onLoadMore);
    on<FeedPostLikeToggled>(_onLikeToggle);
    on<FeedConnectivityChanged>(_onConnectivityChanged);

    // Listen to connectivity changes
    _connectivitySub = _connectivityService.onConnectivityChanged.listen((
      online,
    ) {
      add(FeedConnectivityChanged(isOnline: online));
    });
  }

  Future<void> _onLoad(FeedLoadRequested event, Emitter<FeedState> emit) async {
    final isOnline = _connectivityService.isOnline;
    emit(state.copyWith(status: FeedStatus.loading, isOffline: !isOnline));

    try {
      if (!isOnline) {
        // Load from cache when offline
        final cachedPosts = await _cacheService.getCachedFeedPosts();
        final cachedLikes = await _cacheService.getCachedLikedPostIds();
        emit(
          state.copyWith(
            status: cachedPosts.isEmpty ? FeedStatus.empty : FeedStatus.loaded,
            posts: cachedPosts,
            likedPostIds: cachedLikes,
            isOffline: true,
          ),
        );
        return;
      }

      final uid = _authService.currentUser!.uid;
      final followingIds = await _feedRepository.getFollowingIds(uid);
      // Include own posts in feed
      final allIds = [...followingIds, uid];
      final posts = await _feedRepository.getFeedPosts(allIds);

      // Check which posts are liked
      final likedIds = <String>{};
      for (final post in posts) {
        final liked = await _postRepository.isPostLiked(post.postId, uid);
        if (liked) likedIds.add(post.postId);
      }

      // Cache liked post IDs
      _cacheService.cacheLikedPostIds(likedIds);

      emit(
        state.copyWith(
          status: posts.isEmpty ? FeedStatus.empty : FeedStatus.loaded,
          posts: posts,
          likedPostIds: likedIds,
          isOffline: false,
          hasReachedEnd: posts.length < AppConstants.feedPageSize,
        ),
      );
    } catch (e) {
      // Try cache as fallback on network errors
      final cachedPosts = await _cacheService.getCachedFeedPosts();
      if (cachedPosts.isNotEmpty) {
        final cachedLikes = await _cacheService.getCachedLikedPostIds();
        emit(
          state.copyWith(
            status: FeedStatus.loaded,
            posts: cachedPosts,
            likedPostIds: cachedLikes,
            isOffline: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FeedStatus.error,
            errorMessage: 'Failed to load feed',
          ),
        );
      }
    }
  }

  Future<void> _onRefresh(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    add(FeedLoadRequested());
  }

  Future<void> _onLoadMore(
    FeedLoadMoreRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedEnd || state.isOffline) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));

    final uid = _authService.currentUser!.uid;
    final followingIds = await _feedRepository.getFollowingIds(uid);
    final allIds = [...followingIds, uid];
    final nextLimit = state.posts.length + AppConstants.feedPageSize;
    final posts = await _feedRepository.getFeedPosts(allIds, nextLimit);

    final likedIds = <String>{};
    for (final post in posts) {
      final liked = await _postRepository.isPostLiked(post.postId, uid);
      if (liked) likedIds.add(post.postId);
    }

    _cacheService.cacheLikedPostIds(likedIds);

    emit(
      state.copyWith(
        status: FeedStatus.loaded,
        posts: posts,
        likedPostIds: likedIds,
        isLoadingMore: false,
        hasReachedEnd: posts.length < nextLimit,
      ),
    );
  }

  Future<void> _onConnectivityChanged(
    FeedConnectivityChanged event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(isOffline: !event.isOnline));
    if (event.isOnline) {
      // Sync offline queue when back online
      await _postRepository.syncOfflineQueue();
      // Reload feed with fresh data
      add(FeedLoadRequested());
    }
  }

  Future<void> _onLikeToggle(
    FeedPostLikeToggled event,
    Emitter<FeedState> emit,
  ) async {
    final uid = _authService.currentUser!.uid;
    final newLiked = Set<String>.from(state.likedPostIds);

    if (event.isLiked) {
      await _postRepository.unlikePost(event.postId, uid);
      newLiked.remove(event.postId);
    } else {
      await _postRepository.likePost(event.postId, uid);
      newLiked.add(event.postId);
    }

    // Update post like count in local state
    final updatedPosts = state.posts.map((p) {
      if (p.postId == event.postId) {
        return PostModel(
          postId: p.postId,
          userId: p.userId,
          username: p.username,
          userProfileImage: p.userProfileImage,
          imageUrl: p.imageUrl,
          caption: p.caption,
          likesCount: p.likesCount + (event.isLiked ? -1 : 1),
          commentsCount: p.commentsCount,
          createdAt: p.createdAt,
        );
      }
      return p;
    }).toList();

    emit(state.copyWith(posts: updatedPosts, likedPostIds: newLiked));
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
