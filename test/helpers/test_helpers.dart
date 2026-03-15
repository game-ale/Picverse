import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/core/local/local_cache_service.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/core/services/connectivity_service.dart';
import 'package:picverse/features/admin/domain/repositories/admin_repository.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';
import 'package:picverse/features/auth/domain/repositories/auth_repository.dart';
import 'package:picverse/features/feed/domain/repositories/feed_repository.dart';
import 'package:picverse/features/notification/domain/repositories/notification_repository.dart';
import 'package:picverse/features/post/domain/repositories/post_repository.dart';
import 'package:picverse/features/profile/domain/repositories/profile_repository.dart';
import 'package:picverse/features/search/domain/repositories/search_repository.dart';

// ─── Repository Mocks ───
class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockPostRepository extends Mock implements PostRepository {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

// ─── Service Mocks ───
class MockAuthService extends Mock implements AuthService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockLocalCacheService extends Mock implements LocalCacheService {}

// ─── Firebase Mocks ───
class MockUser extends Mock implements User {}

// ─── Fallback Values ───
class FakeFile extends Fake implements File {}

// ─── Test Data Factories ───
UserModel createTestUser({
  String userId = 'user1',
  String username = 'testuser',
  String email = 'test@test.com',
  String bio = 'Test bio',
  String profileImage = 'https://img.test/avatar.jpg',
  int followersCount = 10,
  int followingCount = 5,
  int postsCount = 3,
  String role = 'user',
  String status = 'active',
}) {
  return UserModel(
    userId: userId,
    username: username,
    email: email,
    bio: bio,
    profileImage: profileImage,
    followersCount: followersCount,
    followingCount: followingCount,
    postsCount: postsCount,
    role: role,
    status: status,
    createdAt: DateTime(2026, 1, 1),
  );
}
