import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class PostCreateRequested extends PostEvent {
  final String imagePath;
  final String caption;

  const PostCreateRequested({required this.imagePath, required this.caption});

  @override
  List<Object?> get props => [imagePath, caption];
}

class PostDeleteRequested extends PostEvent {
  final String postId;

  const PostDeleteRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class PostCommentsLoadRequested extends PostEvent {
  final String postId;

  const PostCommentsLoadRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class PostCommentsLoadMoreRequested extends PostEvent {
  final String postId;

  const PostCommentsLoadMoreRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class PostCommentAdded extends PostEvent {
  final String postId;
  final String text;

  const PostCommentAdded({required this.postId, required this.text});

  @override
  List<Object?> get props => [postId, text];
}

class PostCommentDeleted extends PostEvent {
  final String commentId;
  final String postId;

  const PostCommentDeleted({required this.commentId, required this.postId});

  @override
  List<Object?> get props => [commentId, postId];
}
