import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> signUpWithEmailAndPassword(
      String email, String password, String username);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}
