/// Hive box names and TypeAdapter type IDs.
class HiveConstants {
  HiveConstants._();

  // ─── Box Names ───
  static const String feedBox = 'feed_cache';
  static const String profileBox = 'profile_cache';
  static const String likedPostsBox = 'liked_posts';
  static const String offlineQueueBox = 'offline_queue';

  // ─── TypeAdapter IDs ───
  static const int userModelTypeId = 0;
  static const int postModelTypeId = 1;
  static const int notificationModelTypeId = 2;
  static const int notificationTypeEnumId = 3;
}
