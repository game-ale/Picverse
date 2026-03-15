import 'dart:io' show File;

abstract class StorageDatasource {
  Future<String> uploadPostImage(String userId, String fileName, File file);
  Future<void> deletePostImage(String userId, String fileName);
  Future<String> uploadProfileImage(String userId, File file);
}
