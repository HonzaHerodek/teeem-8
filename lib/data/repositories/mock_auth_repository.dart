import 'package:myapp/data/models/user_model.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    // Simulate a successful sign-in
    _currentUser = UserModel(
      id: 'user123',
      email: email,
      username: 'Test User',
    );
    return _currentUser;
  }

  @override
  Future<UserModel?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    // Simulate a successful sign-up
    _currentUser = UserModel(
      id: 'user123',
      email: email,
      username: username,
    );
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    // Simulate a sign-out
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
}
