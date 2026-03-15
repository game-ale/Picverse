import 'package:equatable/equatable.dart';

import 'package:picverse/features/post/data/models/comment_model.dart';

enum PostStatus { initial, loading, success, error }

class PostState extends Equatable {
  final PostStatus status;
  final List<CommentModel> comments;
  final String? errorMessage;

  const PostState({
    this.status = PostStatus.initial,
    this.comments = const [],
    this.errorMessage,
  });

  PostState copyWith({
    PostStatus? status,
    List<CommentModel>? comments,
    String? errorMessage,
  }) {
    return PostState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, comments, errorMessage];
}
