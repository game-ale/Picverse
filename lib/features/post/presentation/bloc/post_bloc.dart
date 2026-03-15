import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/features/auth/domain/repositories/auth_repository.dart';
import 'package:picverse/features/post/domain/repositories/post_repository.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/post/presentation/bloc/post_event.dart';
import 'package:picverse/features/post/presentation/bloc/post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;
  final AuthService _authService;

  PostBloc({
    required PostRepository postRepository,
    required AuthRepository authRepository,
    required AuthService authService,
  }) : _postRepository = postRepository,
       _authRepository = authRepository,
       _authService = authService,
       super(const PostState()) {
    on<PostCreateRequested>(_onCreate);
    on<PostDeleteRequested>(_onDelete);
    on<PostCommentsLoadRequested>(_onLoadComments);
    on<PostCommentAdded>(_onAddComment);
    on<PostCommentDeleted>(_onDeleteComment);
  }

  Future<void> _onCreate(
    PostCreateRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    try {
      final profile = await _authRepository.getCurrentUserProfile();
      if (profile == null) {
        emit(
          state.copyWith(
            status: PostStatus.error,
            errorMessage: 'User not found',
          ),
        );
        return;
      }

      await _postRepository.createPost(
        userId: profile.userId,
        username: profile.username,
        userProfileImage: profile.profileImage,
        imageFile: File(event.imagePath),
        caption: event.caption,
      );
      emit(state.copyWith(status: PostStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.error,
          errorMessage: 'Failed to create post',
        ),
      );
    }
  }

  Future<void> _onDelete(
    PostDeleteRequested event,
    Emitter<PostState> emit,
  ) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _postRepository.deletePost(event.postId, uid);
  }

  Future<void> _onLoadComments(
    PostCommentsLoadRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    try {
      final comments = await _postRepository.getComments(event.postId);
      emit(state.copyWith(status: PostStatus.success, comments: comments));
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.error,
          errorMessage: 'Failed to load comments',
        ),
      );
    }
  }

  Future<void> _onAddComment(
    PostCommentAdded event,
    Emitter<PostState> emit,
  ) async {
    try {
      final profile = await _authRepository.getCurrentUserProfile();
      if (profile == null) return;

      await _postRepository.addComment(
        postId: event.postId,
        userId: profile.userId,
        username: profile.username,
        text: event.text,
      );
      // Reload comments
      add(PostCommentsLoadRequested(postId: event.postId));
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.error,
          errorMessage: 'Failed to add comment',
        ),
      );
    }
  }

  Future<void> _onDeleteComment(
    PostCommentDeleted event,
    Emitter<PostState> emit,
  ) async {
    await _postRepository.deleteComment(event.commentId, event.postId);
    add(PostCommentsLoadRequested(postId: event.postId));
  }
}
