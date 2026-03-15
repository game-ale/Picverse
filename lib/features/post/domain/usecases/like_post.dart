import 'package:picverse/core/usecases/usecase.dart';
import 'package:picverse/features/post/domain/repositories/post_repository.dart';

class LikePost extends UseCase<void, LikePostParams> {
  final PostRepository repository;

  LikePost(this.repository);

  @override
  Future<void> call(LikePostParams params) {
    return repository.likePost(params.postId, params.userId);
  }
}

class LikePostParams {
  final String postId;
  final String userId;

  const LikePostParams({required this.postId, required this.userId});
}
