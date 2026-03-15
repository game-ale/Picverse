import 'dart:io';

import 'package:picverse/core/usecases/usecase.dart';
import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/post/domain/repositories/post_repository.dart';

class CreatePost extends UseCase<PostModel, CreatePostParams> {
  final PostRepository repository;

  CreatePost(this.repository);

  @override
  Future<PostModel> call(CreatePostParams params) {
    return repository.createPost(
      userId: params.userId,
      username: params.username,
      userProfileImage: params.userProfileImage,
      imageFile: params.imageFile,
      caption: params.caption,
    );
  }
}

class CreatePostParams {
  final String userId;
  final String username;
  final String userProfileImage;
  final File imageFile;
  final String caption;

  const CreatePostParams({
    required this.userId,
    required this.username,
    required this.userProfileImage,
    required this.imageFile,
    required this.caption,
  });
}
