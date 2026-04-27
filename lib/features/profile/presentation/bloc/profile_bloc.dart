import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/features/post/domain/repositories/post_repository.dart';
import 'package:picverse/features/profile/domain/repositories/profile_repository.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_event.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final PostRepository _postRepository;
  final AuthService _authService;

  ProfileBloc({
    required ProfileRepository profileRepository,
    required PostRepository postRepository,
    required AuthService authService,
  }) : _profileRepository = profileRepository,
       _postRepository = postRepository,
       _authService = authService,
       super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileSaveRequested>(_onSaveProfile);
    on<ProfileUpdateBioRequested>(_onUpdateBio);
    on<ProfileUpdateUsernameRequested>(_onUpdateUsername);
    on<ProfileUpdateImageRequested>(_onUpdateImage);
    on<ProfileFollowToggled>(_onFollowToggle);
    on<ProfileFollowersRequested>(_onLoadFollowers);
    on<ProfileFollowingRequested>(_onLoadFollowing);
  }

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final currentUid = _authService.currentUser?.uid;
      final isCurrentUser = currentUid == event.userId;
      final user = await _profileRepository.getUser(event.userId);
      final posts = await _postRepository.getUserPosts(event.userId);
      final isFollowing = !isCurrentUser && currentUid != null
          ? await _profileRepository.isFollowing(currentUid, event.userId)
          : false;

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: user,
          posts: posts,
          isFollowing: isFollowing,
          isCurrentUser: isCurrentUser,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Failed to load profile',
        ),
      );
    }
  }

  Future<void> _onUpdateBio(
    ProfileUpdateBioRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _profileRepository.updateBio(uid, event.bio);
    final current = state.user;
    if (current != null) {
      emit(state.copyWith(user: current.copyWith(bio: event.bio)));
      return;
    }
    final user = await _profileRepository.getUser(uid);
    emit(state.copyWith(user: user));
  }

  Future<void> _onUpdateUsername(
    ProfileUpdateUsernameRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _profileRepository.updateUsername(uid, event.username);
    final current = state.user;
    if (current != null) {
      emit(state.copyWith(user: current.copyWith(username: event.username)));
      return;
    }
    final user = await _profileRepository.getUser(uid);
    emit(state.copyWith(user: user));
  }

  Future<void> _onUpdateImage(
    ProfileUpdateImageRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final imageUrl = await _profileRepository.updateProfileImage(
      uid,
      File(event.imagePath),
    );
    final current = state.user;
    if (current != null) {
      emit(state.copyWith(user: current.copyWith(profileImage: imageUrl)));
      return;
    }
    final user = await _profileRepository.getUser(uid);
    emit(state.copyWith(user: user));
  }

  Future<void> _onSaveProfile(
    ProfileSaveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final uid = _authService.currentUser?.uid;
    final current = state.user;
    if (uid == null || current == null) return;

    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));

    try {
      final normalizedUsername = event.username?.trim();
      final normalizedBio = event.bio?.trim();

      var nextUser = current;

      if (normalizedUsername != null &&
          normalizedUsername.isNotEmpty &&
          normalizedUsername != current.username) {
        await _profileRepository.updateUsername(uid, normalizedUsername);
        nextUser = nextUser.copyWith(username: normalizedUsername);
      }

      if (normalizedBio != null && normalizedBio != current.bio) {
        await _profileRepository.updateBio(uid, normalizedBio);
        nextUser = nextUser.copyWith(bio: normalizedBio);
      }

      if (event.imagePath != null && event.imagePath!.isNotEmpty) {
        final imageUrl = await _profileRepository.updateProfileImage(
          uid,
          File(event.imagePath!),
        );
        nextUser = nextUser.copyWith(profileImage: imageUrl);
      }

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: nextUser,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Failed to save profile changes: $e',
        ),
      );
    }
  }

  Future<void> _onFollowToggle(
    ProfileFollowToggled event,
    Emitter<ProfileState> emit,
  ) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    if (state.isFollowing) {
      await _profileRepository.unfollowUser(uid, event.targetUserId);
    } else {
      await _profileRepository.followUser(uid, event.targetUserId);
    }
    emit(state.copyWith(isFollowing: !state.isFollowing));
    // Reload profile to get updated counts
    add(ProfileLoadRequested(userId: event.targetUserId));
  }

  Future<void> _onLoadFollowers(
    ProfileFollowersRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final followers = await _profileRepository.getFollowers(event.userId);
    emit(state.copyWith(followers: followers));
  }

  Future<void> _onLoadFollowing(
    ProfileFollowingRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final following = await _profileRepository.getFollowing(event.userId);
    emit(state.copyWith(following: following));
  }
}
