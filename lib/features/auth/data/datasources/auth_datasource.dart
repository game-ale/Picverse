import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDatasource {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> registerWithEmail(String email, String password);
  Future<UserCredential?> signInWithGoogle();
  Future<void> resetPassword(String email);
  Future<void> signOut();
}
