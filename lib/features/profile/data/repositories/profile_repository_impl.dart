import 'dart:io';

import 'package:picverse/features/profile/domain/repositories/profile_repository.dart';
import 'package:picverse/core/services/connectivity_service.dart';
import 'package:picverse/core/services/firestore_service.dart';
import 'package:picverse/core/services/storage_service.dart';
import 'package:picverse/core/local/local_cache_service.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final LocalCacheService _cacheService;
  final ConnectivityService _connectivityService;

  ProfileRepositoryImpl({
    required FirestoreService firestoreService,
    required StorageService storageService,
    required LocalCacheService cacheService,
    required ConnectivityService connectivityService,
  }) : _firestoreService = firestoreService,
       _storageService = storageService,
       _cacheService = cacheService,
       _connectivityService = connectivityService;

  @override
  Future<UserModel?> getUser(String userId) async {
    if (!_connectivityService.isOnline) {
      return _cacheService.getCachedProfile(userId);
    }
    final user = await _firestoreService.getUser(userId);
    if (user != null) _cacheService.cacheProfile(user);
    return user;
  }

  @override
  Stream<UserModel?> userStream(String userId) {
    return _firestoreService.userStream(userId);
  }

  @override
  Future<void> updateBio(String userId, String bio) {
    return _firestoreService.updateUser(userId, {'bio': bio});
  }

  @override
  Future<void> updateUsername(String userId, String username) {
    return _firestoreService.updateUser(userId, {'username': username});
  }

  @override
  Future<String> updateProfileImage(String userId, File imageFile) async {
    final url = await _storageService.uploadProfileImage(userId, imageFile);
    await _firestoreService.updateUser(userId, {'profileImage': url});
    return url;
  }

  @override
  Future<List<UserModel>> searchUsers(String query) {
    return _firestoreService.searchUsers(query);
  }

  @override
  Future<bool> isFollowing(String currentUserId, String targetUserId) {
    return _firestoreService.isFollowing(currentUserId, targetUserId);
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) {
    return _firestoreService.followUser(currentUserId, targetUserId);
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) {
    return _firestoreService.unfollowUser(currentUserId, targetUserId);
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) {
    return _firestoreService.getFollowers(userId);
  }

  @override
  Future<List<UserModel>> getFollowing(String userId) {
    return _firestoreService.getFollowing(userId);
  }
}
