import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/features/post/presentation/bloc/post_bloc.dart';
import 'package:picverse/features/post/presentation/bloc/post_event.dart';
import 'package:picverse/features/post/presentation/bloc/post_state.dart';

import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockPostRepository mockPostRepo;
  late MockAuthRepository mockAuthRepo;
  late MockAuthService mockAuthService;
  late MockUser mockUser;
  late PostBloc postBloc;

  final tUser = createTestUser();
  final tComments = [createTestComment(), createTestComment(commentId: 'c2')];

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockPostRepo = MockPostRepository();
    mockAuthRepo = MockAuthRepository();
    mockAuthService = MockAuthService();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('user1');
    when(() => mockAuthService.currentUser).thenReturn(mockUser);

    postBloc = PostBloc(
      postRepository: mockPostRepo,
      authRepository: mockAuthRepo,
      authService: mockAuthService,
    );
  });

  tearDown(() => postBloc.close());

  group('PostBloc', () {
    test('initial state is correct', () {
      expect(postBloc.state, const PostState());
      expect(postBloc.state.status, PostStatus.initial);
    });

    group('PostCreateRequested', () {
      blocTest<PostBloc, PostState>(
        'emits [loading, success] when post created',
        setUp: () {
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
        },
        build: () => postBloc,
        act: (bloc) => bloc.add(
          const PostCreateRequested(
            imagePath: '/tmp/photo.jpg',
            caption: 'Hello world',
          ),
        ),
        expect: () => [
          const PostState(status: PostStatus.loading),
          const PostState(status: PostStatus.success),
        ],
      );

      blocTest<PostBloc, PostState>(
        'emits [loading, error] when profile is null',
        setUp: () {
          when(
            () => mockAuthRepo.getCurrentUserProfile(),
          ).thenAnswer((_) async => null);
        },
        build: () => postBloc,
        act: (bloc) => bloc.add(
          const PostCreateRequested(
            imagePath: '/tmp/photo.jpg',
            caption: 'Hello',
          ),
        ),
        expect: () => [
          const PostState(status: PostStatus.loading),
          const PostState(
            status: PostStatus.error,
            errorMessage: 'User not found',
          ),
        ],
      );

      blocTest<PostBloc, PostState>(
        'emits [loading, error] on exception',
        setUp: () {
          when(
            () => mockAuthRepo.getCurrentUserProfile(),
          ).thenThrow(Exception('network'));
        },
        build: () => postBloc,
        act: (bloc) => bloc.add(
          const PostCreateRequested(
            imagePath: '/tmp/photo.jpg',
            caption: 'Hello',
          ),
        ),
        expect: () => [
          const PostState(status: PostStatus.loading),
          const PostState(
            status: PostStatus.error,
            errorMessage: 'Failed to create post',
          ),
        ],
      );
    });

    group('PostDeleteRequested', () {
      blocTest<PostBloc, PostState>(
        'calls deletePost on repository',
        setUp: () {
          when(
            () => mockPostRepo.deletePost('post1', 'user1'),
          ).thenAnswer((_) async {});
        },
        build: () => postBloc,
        act: (bloc) => bloc.add(const PostDeleteRequested(postId: 'post1')),
        verify: (_) {
          verify(() => mockPostRepo.deletePost('post1', 'user1')).called(1);
        },
      );
    });

    group('PostCommentsLoadRequested', () {
      blocTest<PostBloc, PostState>(
        'emits [loading, success with comments]',
        setUp: () {
          when(
            () => mockPostRepo.getComments('post1'),
          ).thenAnswer((_) async => tComments);
        },
        build: () => postBloc,
        act: (bloc) =>
            bloc.add(const PostCommentsLoadRequested(postId: 'post1')),
        expect: () => [
          const PostState(status: PostStatus.loading),
          PostState(
            status: PostStatus.success,
            comments: tComments,
            hasReachedEnd: true,
          ),
        ],
      );

      blocTest<PostBloc, PostState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(
            () => mockPostRepo.getComments('post1'),
          ).thenThrow(Exception('fail'));
        },
        build: () => postBloc,
        act: (bloc) =>
            bloc.add(const PostCommentsLoadRequested(postId: 'post1')),
        expect: () => [
          const PostState(status: PostStatus.loading),
          const PostState(
            status: PostStatus.error,
            errorMessage: 'Failed to load comments',
          ),
        ],
      );
    });

    group('PostCommentAdded', () {
      blocTest<PostBloc, PostState>(
        'adds comment and reloads comments',
        setUp: () {
          when(
            () => mockAuthRepo.getCurrentUserProfile(),
          ).thenAnswer((_) async => tUser);
          when(
            () => mockPostRepo.addComment(
              postId: any(named: 'postId'),
              userId: any(named: 'userId'),
              username: any(named: 'username'),
              text: any(named: 'text'),
            ),
          ).thenAnswer((_) async => createTestComment());
          when(
            () => mockPostRepo.getComments('post1'),
          ).thenAnswer((_) async => tComments);
        },
        build: () => postBloc,
        act: (bloc) =>
            bloc.add(const PostCommentAdded(postId: 'post1', text: 'Nice!')),
        expect: () => [
          // PostCommentsLoadRequested is dispatched, emitting loading + success
          const PostState(status: PostStatus.loading),
          PostState(
            status: PostStatus.success,
            comments: tComments,
            hasReachedEnd: true,
          ),
        ],
      );

      blocTest<PostBloc, PostState>(
        'emits error when add comment fails',
        setUp: () {
          when(
            () => mockAuthRepo.getCurrentUserProfile(),
          ).thenThrow(Exception('fail'));
        },
        build: () => postBloc,
        act: (bloc) =>
            bloc.add(const PostCommentAdded(postId: 'post1', text: 'Nice!')),
        expect: () => [
          const PostState(
            status: PostStatus.error,
            errorMessage: 'Failed to add comment',
          ),
        ],
      );
    });

    group('PostCommentDeleted', () {
      blocTest<PostBloc, PostState>(
        'deletes comment and reloads',
        setUp: () {
          when(
            () => mockPostRepo.deleteComment('c1', 'post1'),
          ).thenAnswer((_) async {});
          when(
            () => mockPostRepo.getComments('post1'),
          ).thenAnswer((_) async => []);
        },
        build: () => postBloc,
        act: (bloc) => bloc.add(
          const PostCommentDeleted(commentId: 'c1', postId: 'post1'),
        ),
        expect: () => [
          // PostCommentsLoadRequested triggers loading + success
          const PostState(status: PostStatus.loading),
          const PostState(
            status: PostStatus.success,
            comments: [],
            hasReachedEnd: true,
          ),
        ],
      );
    });
  });
}
