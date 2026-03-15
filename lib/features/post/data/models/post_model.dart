import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:picverse/features/post/domain/entities/post.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.postId,
    required super.userId,
    required super.username,
    super.userProfileImage,
    required super.imageUrl,
    super.caption,
    super.likesCount,
    super.commentsCount,
    required super.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userProfileImage: data['userProfileImage'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'userProfileImage': userProfileImage,
      'imageUrl': imageUrl,
      'caption': caption,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
