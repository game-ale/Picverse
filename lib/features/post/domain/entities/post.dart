import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String postId;
  final String userId;
  final String username;
  final String userProfileImage;
  final String imageUrl;
  final String caption;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  const PostEntity({
    required this.postId,
    required this.userId,
    required this.username,
    this.userProfileImage = '',
    required this.imageUrl,
    this.caption = '',
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [postId];
}
