import 'package:equatable/equatable.dart';

import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserModel? user;
  final List<PostModel> posts;
  final bool isFollowing;
  final bool isCurrentUser;
  final List<UserModel> followers;
  final List<UserModel> following;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.posts = const [],
    this.isFollowing = false,
    this.isCurrentUser = false,
    this.followers = const [],
    this.following = const [],
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    List<PostModel>? posts,
    bool? isFollowing,
    bool? isCurrentUser,
    List<UserModel>? followers,
    List<UserModel>? following,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      posts: posts ?? this.posts,
      isFollowing: isFollowing ?? this.isFollowing,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    posts,
    isFollowing,
    isCurrentUser,
    followers,
    following,
    errorMessage,
  ];
}
