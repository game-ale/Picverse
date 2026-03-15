import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:picverse/features/post/domain/entities/comment.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.commentId,
    required super.postId,
    required super.userId,
    required super.username,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      commentId: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
