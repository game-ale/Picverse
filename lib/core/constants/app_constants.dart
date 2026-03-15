class AppConstants {
  AppConstants._();

  static const String appName = 'Picverse';
  static const int feedPageSize = 20;
  static const int maxPostsPerDay = 10;
  static const int minPasswordLength = 6;
  static const int maxBioLength = 150;
  static const int maxCaptionLength = 2200;
  static const double imageCompressionQuality = 70;

  // Supabase storage buckets
  static const String postImagesBucket = 'post-images';
  static const String profileImagesBucket = 'profile-images';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String followsCollection = 'follows';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';
}
