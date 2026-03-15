import 'package:firebase_auth/firebase_auth.dart';

import 'package:picverse/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String username,
  });
  Future<UserModel?> signInWithGoogle();
  Future<void> resetPassword(String email);
  Future<void> signOut();
  Future<UserModel?> getCurrentUserProfile();
}
