import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:picverse/core/constants/app_constants.dart';
import 'package:picverse/core/data/datasources/storage_datasource.dart';

class StorageService implements StorageDatasource {
  SupabaseClient get _client => Supabase.instance.client;

  Future<String> uploadPostImage(
    String userId,
    String fileName,
    File file,
  ) async {
    final path = '$userId/$fileName';
    await _client.storage
        .from(AppConstants.postImagesBucket)
        .upload(path, file);
    return _client.storage
        .from(AppConstants.postImagesBucket)
        .getPublicUrl(path);
  }

  Future<void> deletePostImage(String userId, String fileName) async {
    final path = '$userId/$fileName';
    await _client.storage.from(AppConstants.postImagesBucket).remove([path]);
  }

  Future<String> uploadProfileImage(String userId, File file) async {
    final path = '$userId/avatar.jpg';
    await _client.storage
        .from(AppConstants.profileImagesBucket)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    return _client.storage
        .from(AppConstants.profileImagesBucket)
        .getPublicUrl(path);
  }
}
