import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_event.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_state.dart';

import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockProfileRepository mockProfileRepo;
  late MockPostRepository mockPostRepo;
  late MockAuthService mockAuthService;
  late MockUser mockUser;
  late ProfileBloc profileBloc;

  final tUser = createTestUser();
  final tPosts = [createTestPost(), createTestPost(postId: 'post2')];

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockProfileRepo = MockProfileRepository();
    mockPostRepo = MockPostRepository();
    mockAuthService = MockAuthService();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('user1');
    when(() => mockAuthService.currentUser).thenReturn(mockUser);

    profileBloc = ProfileBloc(
      profileRepository: mockProfileRepo,
      postRepository: mockPostRepo,
      authService: mockAuthService,
    );
  });

  tearDown(() => profileBloc.close());

  group('ProfileBloc', () {
    test('initial state is correct', () {
      expect(profileBloc.state, const ProfileState());
      expect(profileBloc.state.status, ProfileStatus.initial);
    });

    group('ProfileLoadRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [loading, loaded] with current user profile',
        setUp: () {
          when(
            () => mockProfileRepo.getUser('user1'),
          ).thenAnswer((_) async => tUser);
          when(
            () => mockPostRepo.getUserPosts('user1'),
          ).thenAnswer((_) async => tPosts);
        },
        build: () => profileBloc,
        act: (bloc) => bloc.add(const ProfileLoadRequested(userId: 'user1')),
        expect: () => [
          isA<ProfileState>().having(
            (s) => s.status,
            'status',
            ProfileStatus.loading,
          ),
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.loaded)
              .having((s) => s.user, 'user', tUser)
              .having((s) => s.posts, 'posts', tPosts)
              .having((s) => s.isCurrentUser, 'isCurrentUser', true)
              .having((s) => s.isFollowing, 'isFollowing', false),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [loading, loaded] with other user + follow check',
        setUp: () {
          final otherUser = createTestUser(userId: 'user2', username: 'other');
          when(
            () => mockProfileRepo.getUser('user2'),
          ).thenAnswer((_) async => otherUser);
          when(
            () => mockPostRepo.getUserPosts('user2'),
          ).thenAnswer((_) async => []);
          when(
            () => mockProfileRepo.isFollowing('user1', 'user2'),
          ).thenAnswer((_) async => true);
        },
        build: () => profileBloc,
        act: (bloc) => bloc.add(const ProfileLoadRequested(userId: 'user2')),
        expect: () => [
          isA<ProfileState>().having(
            (s) => s.status,
            'status',
            ProfileStatus.loading,
          ),
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.loaded)
              .having((s) => s.isFollowing, 'isFollowing', true)
              .having((s) => s.isCurrentUser, 'isCurrentUser', false),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(
            () => mockProfileRepo.getUser(any()),
          ).thenThrow(Exception('fail'));
          when(
            () => mockPostRepo.getUserPosts(any()),
          ).thenThrow(Exception('fail'));
        },
        build: () => profileBloc,
        act: (bloc) => bloc.add(const ProfileLoadRequested(userId: 'user1')),
        expect: () => [
          isA<ProfileState>().having(
            (s) => s.status,
            'status',
            ProfileStatus.loading,
          ),
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.error)
              .having((s) => s.errorMessage, 'msg', 'Failed to load profile'),
        ],
      );
    });

    group('ProfileUpdateBioRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'updates bio and reloads user',
        setUp: () {
          when(
            () => mockProfileRepo.updateBio('user1', 'new bio'),
          ).thenAnswer((_) async {});
          when(
            () => mockProfileRepo.getUser('user1'),
          ).thenAnswer((_) async => tUser.copyWith(bio: 'new bio'));
        },
        build: () => profileBloc,
        act: (bloc) =>
            bloc.add(const ProfileUpdateBioRequested(bio: 'new bio')),
        expect: () => [
          isA<ProfileState>().having((s) => s.user?.bio, 'bio', 'new bio'),
        ],
      );
    });

    group('ProfileUpdateUsernameRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'updates username and reloads user',
        setUp: () {
          when(
            () => mockProfileRepo.updateUsername('user1', 'newname'),
          ).thenAnswer((_) async {});
          when(
            () => mockProfileRepo.getUser('user1'),
          ).thenAnswer((_) async => tUser.copyWith(username: 'newname'));
        },
        build: () => profileBloc,
        act: (bloc) =>
            bloc.add(const ProfileUpdateUsernameRequested(username: 'newname')),
        expect: () => [
          isA<ProfileState>().having(
            (s) => s.user?.username,
            'username',
            'newname',
          ),
        ],
      );
    });

    group('ProfileUpdateImageRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'updates profile image',
        setUp: () {
          when(
            () => mockProfileRepo.updateProfileImage('user1', any()),
          ).thenAnswer((_) async => 'new_url');
          when(
            () => mockProfileRepo.getUser('user1'),
          ).thenAnswer((_) async => tUser.copyWith(profileImage: 'new_url'));
        },
        build: () => profileBloc,
        act: (bloc) => bloc.add(
          const ProfileUpdateImageRequested(imagePath: '/tmp/img.jpg'),
        ),
        expect: () => [
          isA<ProfileState>().having(
            (s) => s.user?.profileImage,
            'image',
            'new_url',
          ),
        ],
      );
    });

    group('ProfileFollowToggled', () {
      blocTest<ProfileBloc, ProfileState>(
        'follows user when not following',
        seed: () => ProfileState(
          status: ProfileStatus.loaded,
          user: createTestUser(userId: 'user2'),
          isFollowing: false,
        ),
        setUp: () {
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
        },
        build: () => profileBloc,
        act: (bloc) =>
            bloc.add(const ProfileFollowToggled(targetUserId: 'user2')),
        expect: () => [
          // Toggle emits isFollowing: true
          isA<ProfileState>().having((s) => s.isFollowing, 'isFollowing', true),
          // Then ProfileLoadRequested triggers: loading
          isA<ProfileState>().having(
            (s) => s.status,
            'status',
            ProfileStatus.loading,
          ),
          // And then loaded
          isA<ProfileState>().having(
            (s) => s.status,
            'status',
            ProfileStatus.loaded,
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'unfollows user when already following',
        seed: () => ProfileState(
          status: ProfileStatus.loaded,
          user: createTestUser(userId: 'user2'),
          isFollowing: true,
        ),
        setUp: () {
          when(
            () => mockProfileRepo.unfollowUser('user1', 'user2'),
          ).thenAnswer((_) async {});
          when(
            () => mockProfileRepo.getUser('user2'),
          ).thenAnswer((_) async => createTestUser(userId: 'user2'));
          when(
            () => mockPostRepo.getUserPosts('user2'),
          ).thenAnswer((_) async => []);
          when(
            () => mockProfileRepo.isFollowing('user1', 'user2'),
          ).thenAnswer((_) async => false);
        },
        build: () => profileBloc,
        act: (bloc) =>
            bloc.add(const ProfileFollowToggled(targetUserId: 'user2')),
        expect: () => [
          isA<ProfileState>().having(
            (s) => s.isFollowing,
            'isFollowing',
            false,
          ),
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
        ],
      );
    });

    group('ProfileFollowersRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'loads followers list',
        setUp: () {
          when(
            () => mockProfileRepo.getFollowers('user1'),
          ).thenAnswer((_) async => [tUser]);
        },
        build: () => profileBloc,
        act: (bloc) =>
            bloc.add(const ProfileFollowersRequested(userId: 'user1')),
        expect: () => [
          isA<ProfileState>().having((s) => s.followers.length, 'count', 1),
        ],
      );
    });

    group('ProfileFollowingRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'loads following list',
        setUp: () {
          when(
            () => mockProfileRepo.getFollowing('user1'),
          ).thenAnswer((_) async => [tUser]);
        },
        build: () => profileBloc,
        act: (bloc) =>
            bloc.add(const ProfileFollowingRequested(userId: 'user1')),
        expect: () => [
          isA<ProfileState>().having((s) => s.following.length, 'count', 1),
        ],
      );
    });
  });
}
