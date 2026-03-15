import 'package:picverse/core/usecases/usecase.dart';
import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/feed/domain/repositories/feed_repository.dart';

class LoadFeed extends UseCase<List<PostModel>, LoadFeedParams> {
  final FeedRepository repository;

  LoadFeed(this.repository);

  @override
  Future<List<PostModel>> call(LoadFeedParams params) async {
    final followingIds = await repository.getFollowingIds(params.userId);
    final allIds = [...followingIds, params.userId];
    return repository.getFeedPosts(allIds);
  }
}

class LoadFeedParams {
  final String userId;

  const LoadFeedParams({required this.userId});
}
