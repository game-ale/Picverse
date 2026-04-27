import 'package:equatable/equatable.dart';

import 'package:picverse/features/post/data/models/comment_model.dart';

enum PostStatus { initial, loading, success, error }

class PostState extends Equatable {
  final PostStatus status;
  final List<CommentModel> comments;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  const PostState({
    this.status = PostStatus.initial,
    this.comments = const [],
    this.errorMessage,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
  });

  PostState copyWith({
    PostStatus? status,
    List<CommentModel>? comments,
    String? errorMessage,
    bool? isLoadingMore,
    bool? hasReachedEnd,
  }) {
    return PostState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }

  @override
  List<Object?> get props => [
    status,
    comments,
    errorMessage,
    isLoadingMore,
    hasReachedEnd,
  ];
}
