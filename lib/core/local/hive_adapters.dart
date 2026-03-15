import 'package:hive_flutter/hive_flutter.dart';

import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';
import 'package:picverse/core/local/hive_constants.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = HiveConstants.userModelTypeId;

  @override
  UserModel read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return UserModel(
      userId: map['userId'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      bio: map['bio'] as String? ?? '',
      profileImage: map['profileImage'] as String? ?? '',
      followersCount: map['followersCount'] as int? ?? 0,
      followingCount: map['followingCount'] as int? ?? 0,
      postsCount: map['postsCount'] as int? ?? 0,
      role: map['role'] as String? ?? 'user',
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeMap({
      'userId': obj.userId,
      'username': obj.username,
      'email': obj.email,
      'bio': obj.bio,
      'profileImage': obj.profileImage,
      'followersCount': obj.followersCount,
      'followingCount': obj.followingCount,
      'postsCount': obj.postsCount,
      'role': obj.role,
      'status': obj.status,
      'createdAt': obj.createdAt.millisecondsSinceEpoch,
    });
  }
}

class PostModelAdapter extends TypeAdapter<PostModel> {
  @override
  final int typeId = HiveConstants.postModelTypeId;

  @override
  PostModel read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return PostModel(
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      userProfileImage: map['userProfileImage'] as String? ?? '',
      imageUrl: map['imageUrl'] as String,
      caption: map['caption'] as String? ?? '',
      likesCount: map['likesCount'] as int? ?? 0,
      commentsCount: map['commentsCount'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  void write(BinaryWriter writer, PostModel obj) {
    writer.writeMap({
      'postId': obj.postId,
      'userId': obj.userId,
      'username': obj.username,
      'userProfileImage': obj.userProfileImage,
      'imageUrl': obj.imageUrl,
      'caption': obj.caption,
      'likesCount': obj.likesCount,
      'commentsCount': obj.commentsCount,
      'createdAt': obj.createdAt.millisecondsSinceEpoch,
    });
  }
}
