import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:picverse/core/constants/app_constants.dart';

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  Future<String> uploadPostImage(
    String userId,
    String fileName,
    File file,
  ) async {
    final path = '$userId/$fileName';
    final ref = _storage.ref().child(AppConstants.postImagesBucket).child(path);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deletePostImage(String userId, String fileName) async {
    final path = '$userId/$fileName';
    await _storage.ref().child(AppConstants.postImagesBucket).child(path).delete();
  }

  Future<String> uploadProfileImage(String userId, File file) async {
    // Use a unique filename so the download URL changes and cached avatars refresh.
    final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref =
        _storage.ref().child(AppConstants.profileImagesBucket).child(path);
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
