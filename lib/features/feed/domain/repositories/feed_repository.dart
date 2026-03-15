import 'package:picverse/features/post/data/models/post_model.dart';

abstract class FeedRepository {
  Future<List<String>> getFollowingIds(String userId);
  Future<List<PostModel>> getFeedPosts(List<String> followingIds);
}
