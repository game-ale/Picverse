import 'package:picverse/core/usecases/usecase.dart';
import 'package:picverse/features/profile/domain/repositories/profile_repository.dart';

class FollowUser extends UseCase<void, FollowUserParams> {
  final ProfileRepository repository;

  FollowUser(this.repository);

  @override
  Future<void> call(FollowUserParams params) {
    return repository.followUser(params.currentUserId, params.targetUserId);
  }
}

class FollowUserParams {
  final String currentUserId;
  final String targetUserId;

  const FollowUserParams({
    required this.currentUserId,
    required this.targetUserId,
  });
}
