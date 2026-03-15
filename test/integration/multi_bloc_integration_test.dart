import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_event.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_state.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_event.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_state.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_event.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_state.dart';
import 'package:picverse/features/post/presentation/bloc/post_bloc.dart';
import 'package:picverse/features/post/presentation/bloc/post_event.dart';
import 'package:picverse/features/post/presentation/bloc/post_state.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_event.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_state.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

/// Integration tests that verify multi-BLoC flows.
void main() {
  late MockAuthRepository mockAuthRepo;
  late MockProfileRepository mockProfileRepo;
  late MockPostRepository mockPostRepo;
  late MockFeedRepository mockFeedRepo;
  late MockNotificationRepository mockNotifRepo;
  late MockAuthService mockAuthService;
  late MockConnectivityService mockConnectivity;
  late MockLocalCacheService mockCache;
  late MockUser mockUser;
  late StreamController<bool> connectivityController;

  final tUser = createTestUser();

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockProfileRepo = MockProfileRepository();
    mockPostRepo = MockPostRepository();
    mockFeedRepo = MockFeedRepository();
    mockNotifRepo = MockNotificationRepository();
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

  tearDown(() => connectivityController.close());

  group('Login → Load Profile flow', () {
    test('after login, profile loads for authenticated user', () async {
      // Step 1: Login
      when(
        () => mockAuthRepo.signInWithEmail(any(), any()),
      ).thenAnswer((_) async => tUser);

      final authBloc = AuthBloc(authRepository: mockAuthRepo);
      authBloc.add(
        const AuthLoginRequested(email: 'test@test.com', password: 'pass'),
      );

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthState>().having(
            (s) => s.status,
            'status',
            AuthStatus.loading,
          ),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.authenticated)
              .having((s) => s.user, 'user', tUser),
        ]),
      );

      // Step 2: Load profile for logged-in user
      when(
        () => mockProfileRepo.getUser('user1'),
      ).thenAnswer((_) async => tUser);
      when(
        () => mockPostRepo.getUserPosts('user1'),
      ).thenAnswer((_) async => [createTestPost()]);

      final profileBloc = ProfileBloc(
        profileRepository: mockProfileRepo,
        postRepository: mockPostRepo,
        authService: mockAuthService,
      );
      profileBloc.add(const ProfileLoadRequested(userId: 'user1'));

      await expectLater(
        profileBloc.stream,
        emitsInOrder([
          isA<ProfileState>().having(
            (s) => s.status,
            'status',
            ProfileStatus.loading,
          ),
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.loaded)
              .having((s) => s.isCurrentUser, 'isCurrentUser', true)
              .having((s) => s.posts.length, 'posts', 1),
        ]),
      );

      await authBloc.close();
      await profileBloc.close();
    });
  });

  group('Create Post → Feed refresh flow', () {
    test('after creating a post, feed shows it', () async {
      final tPost = createTestPost();

      // Step 1: Create post
      when(
        () => mockAuthRepo.getCurrentUserProfile(),
      ).thenAnswer((_) async => tUser);
      when(
        () => mockPostRepo.createPost(
          userId: any(named: 'userId'),
          username: any(named: 'username'),
          userProfileImage: any(named: 'userProfileImage'),
          imageFile: any(named: 'imageFile'),
          caption: any(named: 'caption'),
        ),
      ).thenAnswer((_) async => createTestPost());

      final postBloc = PostBloc(
        postRepository: mockPostRepo,
        authRepository: mockAuthRepo,
        authService: mockAuthService,
      );
      postBloc.add(
        const PostCreateRequested(
          imagePath: '/tmp/pic.jpg',
          caption: 'New post',
        ),
      );

      await expectLater(
        postBloc.stream,
        emitsInOrder([
          isA<PostState>().having(
            (s) => s.status,
            'status',
            PostStatus.loading,
          ),
          isA<PostState>().having(
            (s) => s.status,
            'status',
            PostStatus.success,
          ),
        ]),
      );

      // Step 2: Refresh feed should include the new post
      when(
        () => mockFeedRepo.getFollowingIds('user1'),
      ).thenAnswer((_) async => []);
      when(
        () => mockFeedRepo.getFeedPosts(['user1']),
      ).thenAnswer((_) async => [tPost]);
      when(
        () => mockPostRepo.isPostLiked(any(), any()),
      ).thenAnswer((_) async => false);
      when(() => mockCache.cacheLikedPostIds(any())).thenAnswer((_) async {});

      final feedBloc = FeedBloc(
        feedRepository: mockFeedRepo,
        postRepository: mockPostRepo,
        authService: mockAuthService,
        connectivityService: mockConnectivity,
        cacheService: mockCache,
      );
      feedBloc.add(FeedLoadRequested());

      await expectLater(
        feedBloc.stream,
        emitsInOrder([
          isA<FeedState>().having(
            (s) => s.status,
            'status',
            FeedStatus.loading,
          ),
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loaded)
              .having((s) => s.posts.length, 'posts', 1),
        ]),
      );

      await postBloc.close();
      await feedBloc.close();
    });
  });

  group('Offline → Online sync flow', () {
    test('offline feed loads cache, online syncs and reloads', () async {
      final cachedPosts = [createTestPost(caption: 'cached')];
      final freshPosts = [
        createTestPost(caption: 'cached'),
        createTestPost(postId: 'p2', caption: 'new'),
      ];

      // Setup: Start offline
      when(() => mockConnectivity.isOnline).thenReturn(false);
      when(
        () => mockCache.getCachedFeedPosts(),
      ).thenAnswer((_) async => cachedPosts);
      when(
        () => mockCache.getCachedLikedPostIds(),
      ).thenAnswer((_) async => <String>{});

      final feedBloc = FeedBloc(
        feedRepository: mockFeedRepo,
        postRepository: mockPostRepo,
        authService: mockAuthService,
        connectivityService: mockConnectivity,
        cacheService: mockCache,
      );

      // Step 1: Load feed while offline
      feedBloc.add(FeedLoadRequested());

      await expectLater(
        feedBloc.stream,
        emitsInOrder([
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loading)
              .having((s) => s.isOffline, 'offline', true),
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loaded)
              .having((s) => s.posts.length, 'posts', 1)
              .having((s) => s.isOffline, 'offline', true),
        ]),
      );

      // Step 2: Go online — should sync and reload
      when(() => mockConnectivity.isOnline).thenReturn(true);
      when(() => mockPostRepo.syncOfflineQueue()).thenAnswer((_) async {});
      when(
        () => mockFeedRepo.getFollowingIds('user1'),
      ).thenAnswer((_) async => []);
      when(
        () => mockFeedRepo.getFeedPosts(['user1']),
      ).thenAnswer((_) async => freshPosts);
      when(
        () => mockPostRepo.isPostLiked(any(), any()),
      ).thenAnswer((_) async => false);
      when(() => mockCache.cacheLikedPostIds(any())).thenAnswer((_) async {});

      feedBloc.add(const FeedConnectivityChanged(isOnline: true));

      await expectLater(
        feedBloc.stream,
        emitsInOrder([
          // isOffline: false
          isA<FeedState>().having((s) => s.isOffline, 'offline', false),
          // Reload: loading
          isA<FeedState>().having(
            (s) => s.status,
            'status',
            FeedStatus.loading,
          ),
          // Reload: loaded with fresh data
          isA<FeedState>()
              .having((s) => s.status, 'status', FeedStatus.loaded)
              .having((s) => s.posts.length, 'posts', 2),
        ]),
      );

      await feedBloc.close();
    });
  });

  group('Follow user → Notifications flow', () {
    test('follow user then check notifications', () async {
      // Step 1: Follow a user
      when(
        () => mockProfileRepo.followUser('user1', 'user2'),
      ).thenAnswer((_) async {});
      when(
        () => mockProfileRepo.getUser('user2'),
      ).thenAnswer((_) async => createTestUser(userId: 'user2'));
      when(
        () => mockPostRepo.getUserPosts('user2'),
      ).thenAnswer((_) async => []);
      when(
        () => mockProfileRepo.isFollowing('user1', 'user2'),
      ).thenAnswer((_) async => true);

      final profileBloc = ProfileBloc(
        profileRepository: mockProfileRepo,
        postRepository: mockPostRepo,
        authService: mockAuthService,
      );

      // Seed: viewing user2's profile, not following
      profileBloc.emit(
        ProfileState(
          status: ProfileStatus.loaded,
          user: createTestUser(userId: 'user2'),
          isFollowing: false,
          isCurrentUser: false,
        ),
      );

      profileBloc.add(const ProfileFollowToggled(targetUserId: 'user2'));

      await expectLater(
        profileBloc.stream,
        emitsInOrder([
          isA<ProfileState>().having((s) => s.isFollowing, 'isFollowing', true),
          isA<ProfileState>().having(
            (s) => s.status,
            'status',
            ProfileStatus.loading,
          ),
          isA<ProfileState>().having(
            (s) => s.status,
            'status',
            ProfileStatus.loaded,
          ),
        ]),
      );

      // Step 2: Load notifications for the followed user (simulating other side)
      final followNotif = createTestNotification(
        actorId: 'user1',
        actorUsername: 'testuser',
        userId: 'user2',
      );
      final otherAuthService = MockAuthService();
      final otherUser = MockUser();
      when(() => otherUser.uid).thenReturn('user2');
      when(() => otherAuthService.currentUser).thenReturn(otherUser);
      when(
        () => mockNotifRepo.getNotifications('user2'),
      ).thenAnswer((_) async => [followNotif]);

      final notifBloc = NotificationBloc(
        notificationRepository: mockNotifRepo,
        authService: otherAuthService,
      );
      notifBloc.add(NotificationLoadRequested());

      await expectLater(
        notifBloc.stream,
        emitsInOrder([
          const NotificationState(status: NotificationStatus.loading),
          isA<NotificationState>()
              .having((s) => s.status, 'status', NotificationStatus.loaded)
              .having((s) => s.notifications.length, 'count', 1),
        ]),
      );

      await profileBloc.close();
      await notifBloc.close();
    });
  });

  group('Like post in feed flow', () {
    test('like a post updates liked set and count', () async {
      final posts = [createTestPost(likesCount: 5)];

      final feedBloc = FeedBloc(
        feedRepository: mockFeedRepo,
        postRepository: mockPostRepo,
        authService: mockAuthService,
        connectivityService: mockConnectivity,
        cacheService: mockCache,
      );

      // Seed the feed state
      feedBloc.emit(
        FeedState(
          status: FeedStatus.loaded,
          posts: posts,
          likedPostIds: const {},
        ),
      );

      when(
        () => mockPostRepo.likePost('post1', 'user1'),
      ).thenAnswer((_) async {});

      feedBloc.add(const FeedPostLikeToggled(postId: 'post1', isLiked: false));

      await expectLater(
        feedBloc.stream,
        emits(
          isA<FeedState>()
              .having((s) => s.likedPostIds.contains('post1'), 'liked', true)
              .having((s) => s.posts.first.likesCount, 'count', 6),
        ),
      );

      await feedBloc.close();
    });
  });
}
