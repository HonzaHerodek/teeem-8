import '../../data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> getUserById(String userId);
  Future<void> updateUser(UserModel user);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<UserModel>> searchUsers(String query);
  Stream<List<UserModel>> getFollowers(String userId);
  Stream<List<UserModel>> getFollowing(String userId);
  Future<void> updateProfileImage(String imagePath);
  Future<void> updateUserSettings(Map<String, dynamic> settings);
  Future<bool> checkUsername(String username);
  Stream<UserModel> getUserStream(String userId);
  Future<void> deleteAccount();
  Future<void> updateNotificationSettings(Map<String, bool> settings);
  Future<Map<String, dynamic>> getUserAnalytics(String userId);
}
