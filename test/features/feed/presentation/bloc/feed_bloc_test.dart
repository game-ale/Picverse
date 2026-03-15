import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_event.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_state.dart';

import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockFeedRepository mockFeedRepo;
  late MockPostRepository mockPostRepo;
  late MockAuthService mockAuthService;
  late MockConnectivityService mockConnectivity;
  late MockLocalCacheService mockCache;
  late MockUser mockUser;
  late StreamController<bool> connectivityController;

  final tPosts = [createTestPost(), createTestPost(postId: 'post2')];

  setUp(() {
    mockFeedRepo = MockFeedRepository();
    mockPostRepo = MockPostRepository();
    mockAuthService = MockAuthService();
    mockConnectivity = MockConnectivityService();
    mockCache = MockLocalCacheService();
    mockUser = MockUser();
    connectivityController = StreamController<bool>.broadcast();

    when(() => mockUser.uid).thenReturn('user1');
    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
    when(() => mockConnectivity.isOnline).thenReturn(true);
  });

  tearDown(() {
    connectivityController.close();
  });

  FeedBloc buildBloc() => FeedBloc(
    feedRepository: mockFeedRepo,
    postRepository: mockPostRepo,
    authService: mockAuthService,
    connectivityService: mockConnectivity,
    cacheService: mockCache,
  );

  group('FeedBloc', () {
    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state, const FeedState());
      expect(bloc.state.status, FeedStatus.initial);
      bloc.close();
    });

    group('FeedLoadRequested (online)', () {
      blocTest<FeedBloc, FeedState>(
        'emits [loading, loaded] with posts and liked ids',
        setUp: () {
          when(
            () => mockFeedRepo.getFollowingIds('user1'),
          ).thenAnswer((_) async => ['user2']);
          when(
            () => mockFeedRepo.getFeedPosts(['user2', 'user1']),
          ).thenAnswer((_) async => tPosts);
          when(
            () => mockPostRepo.isPostLiked('post1', 'user1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockPostRepo.isPostLiked('post2', 'user1'),
          ).thenAnswer((_) async => false);
          when(
            () => mockCache.cacheLikedPostIds(any()),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(FeedLoadRequested()),
        expect: () => [
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loading)
              .having((s) => s.isOffline, 'isOffline', false),
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loaded)
              .having((s) => s.posts.length, 'posts', 2)
              .having((s) => s.likedPostIds, 'liked', {'post1'})
              .having((s) => s.isOffline, 'isOffline', false),
        ],
      );

      blocTest<FeedBloc, FeedState>(
        'emits [loading, empty] when no posts',
        setUp: () {
          when(
            () => mockFeedRepo.getFollowingIds('user1'),
          ).thenAnswer((_) async => []);
          when(
            () => mockFeedRepo.getFeedPosts(['user1']),
          ).thenAnswer((_) async => []);
          when(
            () => mockCache.cacheLikedPostIds(any()),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(FeedLoadRequested()),
        expect: () => [
          isA<FeedState>().having(
            (s) => s.status,
            'status',
            FeedStatus.loading,
          ),
          isA<FeedState>().having((s) => s.status, 'status', FeedStatus.empty),
        ],
      );
    });

    group('FeedLoadRequested (offline)', () {
      blocTest<FeedBloc, FeedState>(
        'loads cached posts when offline',
        setUp: () {
          when(() => mockConnectivity.isOnline).thenReturn(false);
          when(
            () => mockCache.getCachedFeedPosts(),
          ).thenAnswer((_) async => tPosts);
          when(
            () => mockCache.getCachedLikedPostIds(),
          ).thenAnswer((_) async => {'post1'});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(FeedLoadRequested()),
        expect: () => [
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loading)
              .having((s) => s.isOffline, 'isOffline', true),
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loaded)
              .having((s) => s.posts.length, 'posts', 2)
              .having((s) => s.isOffline, 'isOffline', true),
        ],
      );

      blocTest<FeedBloc, FeedState>(
        'emits empty when no cached posts offline',
        setUp: () {
          when(() => mockConnectivity.isOnline).thenReturn(false);
          when(
            () => mockCache.getCachedFeedPosts(),
          ).thenAnswer((_) async => []);
          when(
            () => mockCache.getCachedLikedPostIds(),
          ).thenAnswer((_) async => <String>{});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(FeedLoadRequested()),
        expect: () => [
          isA<FeedState>().having(
            (s) => s.status,
            'status',
            FeedStatus.loading,
          ),
          isA<FeedState>().having((s) => s.status, 'status', FeedStatus.empty),
        ],
      );
    });

    group('FeedLoadRequested (error with cache fallback)', () {
      blocTest<FeedBloc, FeedState>(
        'falls back to cache on network error',
        setUp: () {
          when(
            () => mockFeedRepo.getFollowingIds('user1'),
          ).thenThrow(Exception('network'));
          when(
            () => mockCache.getCachedFeedPosts(),
          ).thenAnswer((_) async => tPosts);
          when(
            () => mockCache.getCachedLikedPostIds(),
          ).thenAnswer((_) async => <String>{});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(FeedLoadRequested()),
        expect: () => [
          isA<FeedState>().having(
            (s) => s.status,
            'status',
            FeedStatus.loading,
          ),
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loaded)
              .having((s) => s.isOffline, 'isOffline', true),
        ],
      );

      blocTest<FeedBloc, FeedState>(
        'emits error when no cache on error',
        setUp: () {
          when(
            () => mockFeedRepo.getFollowingIds('user1'),
          ).thenThrow(Exception('network'));
          when(
            () => mockCache.getCachedFeedPosts(),
          ).thenAnswer((_) async => []);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(FeedLoadRequested()),
        expect: () => [
          isA<FeedState>().having(
            (s) => s.status,
            'status',
            FeedStatus.loading,
          ),
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.error)
              .having((s) => s.errorMessage, 'msg', 'Failed to load feed'),
        ],
      );
    });

    group('FeedPostLikeToggled', () {
      blocTest<FeedBloc, FeedState>(
        'likes a post (adds to liked set, increments count)',
        seed: () => FeedState(
          status: FeedStatus.loaded,
          posts: tPosts,
          likedPostIds: const {},
        ),
        setUp: () {
          when(
            () => mockPostRepo.likePost('post1', 'user1'),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const FeedPostLikeToggled(postId: 'post1', isLiked: false),
        ),
        expect: () => [
          isA<FeedState>()
              .having((s) => s.likedPostIds.contains('post1'), 'liked', true)
              .having(
                (s) => s.posts.first.likesCount,
                'count',
                tPosts.first.likesCount + 1,
              ),
        ],
      );

      blocTest<FeedBloc, FeedState>(
        'unlikes a post (removes from liked set, decrements count)',
        seed: () => FeedState(
          status: FeedStatus.loaded,
          posts: tPosts,
          likedPostIds: const {'post1'},
        ),
        setUp: () {
          when(
            () => mockPostRepo.unlikePost('post1', 'user1'),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const FeedPostLikeToggled(postId: 'post1', isLiked: true)),
        expect: () => [
          isA<FeedState>()
              .having((s) => s.likedPostIds.contains('post1'), 'liked', false)
              .having(
                (s) => s.posts.first.likesCount,
                'count',
                tPosts.first.likesCount - 1,
              ),
        ],
      );
    });

    group('FeedConnectivityChanged', () {
      blocTest<FeedBloc, FeedState>(
        'syncs offline queue and reloads when back online',
        setUp: () {
          when(() => mockPostRepo.syncOfflineQueue()).thenAnswer((_) async {});
          when(
            () => mockFeedRepo.getFollowingIds('user1'),
          ).thenAnswer((_) async => []);
          when(
            () => mockFeedRepo.getFeedPosts(['user1']),
          ).thenAnswer((_) async => tPosts);
          when(
            () => mockPostRepo.isPostLiked(any(), any()),
          ).thenAnswer((_) async => false);
          when(
            () => mockCache.cacheLikedPostIds(any()),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const FeedConnectivityChanged(isOnline: true)),
        expect: () => [
          // isOffline: false
          isA<FeedState>().having((s) => s.isOffline, 'isOffline', false),
          // Then FeedLoadRequested triggers loading + loaded
          isA<FeedState>().having(
            (s) => s.status,
            'status',
            FeedStatus.loading,
          ),
          isA<FeedState>().having((s) => s.status, 'status', FeedStatus.loaded),
        ],
      );

      blocTest<FeedBloc, FeedState>(
        'sets offline flag when going offline',
        build: buildBloc,
        act: (bloc) => bloc.add(const FeedConnectivityChanged(isOnline: false)),
        expect: () => [
          isA<FeedState>().having((s) => s.isOffline, 'isOffline', true),
        ],
      );
    });
  });
}
