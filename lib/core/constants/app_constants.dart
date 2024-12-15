class AppConstants {
  // App Information
  static const String appName = 'IDX';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Interactive Multi-Step Posts Platform';

  // API and Backend
  static const String baseUrl = 'https://your-api-base-url';
  static const int apiTimeout = 30000; // milliseconds

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String followersCollection = 'followers';
  static const String followingCollection = 'following';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String userAvatarsPath = 'user_avatars';
  static const String postMediaPath = 'post_media';
  static const String postThumbnailsPath = 'post_thumbnails';
  static const String arModelsPath = 'ar_models';

  // Asset Paths
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';
  static const String modelPath = 'assets/models';

  // Cache Configuration
  static const int maxCacheAge = 7; // days
  static const int maxCacheSize = 50; // MB

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Media Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxImagesPerPost = 10;
  static const Duration maxVideoLength = Duration(minutes: 5);

  // Post Configuration
  static const int maxPostSteps = 20;
  static const int minPostSteps = 1;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxStepTitleLength = 50;
  static const int maxStepDescriptionLength = 200;

  // User Configuration
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 150;
  static const int minPasswordLength = 8;

  // Timeouts and Intervals
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration refreshTokenInterval = Duration(hours: 1);
  static const Duration cacheDuration = Duration(days: 7);

  // Error Messages
  static const String defaultErrorMessage =
      'An error occurred. Please try again.';
  static const String networkErrorMessage =
      'Please check your internet connection.';
  static const String sessionExpiredMessage =
      'Your session has expired. Please login again.';
  static const String invalidCredentialsMessage = 'Invalid email or password.';
  static const String weakPasswordMessage =
      'Password should be at least 8 characters long.';
  static const String emailInUseMessage = 'This email is already in use.';
  static const String usernameInUseMessage = 'This username is already taken.';
  static const String unauthorizedMessage =
      'You are not authorized to perform this action.';

  // Success Messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String signupSuccessMessage = 'Account created successfully!';
  static const String postCreatedMessage = 'Post created successfully!';
  static const String postUpdatedMessage = 'Post updated successfully!';
  static const String postDeletedMessage = 'Post deleted successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';

  // Feature Flags
  static const bool enableARFeatures = true;
  static const bool enableVRFeatures = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Analytics Events
  static const String eventPostCreated = 'post_created';
  static const String eventPostViewed = 'post_viewed';
  static const String eventPostLiked = 'post_liked';
  static const String eventPostShared = 'post_shared';
  static const String eventUserFollowed = 'user_followed';
  static const String eventCommentAdded = 'comment_added';
  static const String eventARInteraction = 'ar_interaction';
  static const String eventVRInteraction = 'vr_interaction';
}
