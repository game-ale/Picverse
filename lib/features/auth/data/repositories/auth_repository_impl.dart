import 'package:firebase_auth/firebase_auth.dart';

import 'package:picverse/features/auth/domain/repositories/auth_repository.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/core/services/firestore_service.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl({
    required AuthService authService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
       _firestoreService = firestoreService;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await _authService.signInWithEmail(email, password);
    final user = await _firestoreService.getUser(credential.user!.uid);
    return user!;
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final credential = await _authService.registerWithEmail(email, password);
    final uid = credential.user!.uid;

    final newUser = UserModel(
      userId: uid,
      username: username.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
    );
    await _firestoreService.createUser(newUser);
    return newUser;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    if (credential == null) return null;

    final uid = credential.user!.uid;
    var user = await _firestoreService.getUser(uid);

    if (user == null) {
      user = UserModel(
        userId: uid,
        username: credential.user!.displayName ?? 'user_$uid',
        email: credential.user!.email ?? '',
        profileImage: credential.user!.photoURL ?? '',
        createdAt: DateTime.now(),
      );
      await _firestoreService.createUser(user);
    }
    return user;
  }

  @override
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  Future<UserModel?> getCurrentUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    return await _firestoreService.getUser(uid);
  }
}
