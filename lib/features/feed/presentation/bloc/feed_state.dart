import 'package:equatable/equatable.dart';

import 'package:picverse/features/post/data/models/post_model.dart';

enum FeedStatus { initial, loading, loaded, error, empty }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<PostModel> posts;
  final Set<String> likedPostIds;
  final String? errorMessage;
  final bool isOffline;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.likedPostIds = const {},
    this.errorMessage,
    this.isOffline = false,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<PostModel>? posts,
    Set<String>? likedPostIds,
    String? errorMessage,
    bool? isOffline,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    likedPostIds,
    errorMessage,
    isOffline,
  ];
}
