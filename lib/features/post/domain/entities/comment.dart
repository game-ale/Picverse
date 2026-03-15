import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  const CommentEntity({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [commentId];
}
