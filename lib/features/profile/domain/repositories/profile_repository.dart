import 'dart:io' show File;

import 'package:picverse/features/auth/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel?> getUser(String userId);
  Stream<UserModel?> userStream(String userId);
  Future<void> updateBio(String userId, String bio);
  Future<void> updateUsername(String userId, String username);
  Future<String> updateProfileImage(String userId, File imageFile);
  Future<List<UserModel>> searchUsers(String query);
  Future<bool> isFollowing(String currentUserId, String targetUserId);
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<List<UserModel>> getFollowers(String userId);
  Future<List<UserModel>> getFollowing(String userId);
}
