import 'dart:async';
import '../../core/errors/app_exception.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  String? _currentUserId;
  final _authStateController = StreamController<bool>.broadcast();
  final _delay = const Duration(milliseconds: 500); // Simulate network delay

  // Mock users data
  final Map<String, _MockUser> _users = {
    'test@example.com': _MockUser(
      email: 'test@example.com',
      password: 'password123',
      userId: 'user_1',
    ),
  };

  MockAuthRepository() {
    // Start with no user logged in
    _currentUserId = null;
    _authStateController.add(false);

    // Auto login after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _currentUserId = 'user_1'; // Set the test user as logged in
      _authStateController.add(true); // Emit authenticated state
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    await Future.delayed(_delay);

    final user = _users[email.toLowerCase()];
    if (user == null || user.password != password) {
      throw AuthException('Invalid email or password');
    }

    _currentUserId = user.userId;
    _authStateController.add(true);
  }

  @override
  Future<void> signUp(String email, String password, String username) async {
    await Future.delayed(_delay);

    if (_users.containsKey(email.toLowerCase())) {
      throw AuthException('Email already in use');
    }

    final userId = 'user_${_users.length + 1}';
    _users[email.toLowerCase()] = _MockUser(
      email: email,
      password: password,
      userId: userId,
    );

    _currentUserId = userId;
    _authStateController.add(true);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(_delay);
    _currentUserId = null;
    _authStateController.add(false);
  }

  @override
  Future<bool> isSignedIn() async {
    await Future.delayed(_delay);
    return _currentUserId != null;
  }

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  @override
  Future<String?> getCurrentUserId() async {
    await Future.delayed(_delay);
    return _currentUserId;
  }

  void dispose() {
    _authStateController.close();
  }
}

class _MockUser {
  final String email;
  final String password;
  final String userId;

  _MockUser({
    required this.email,
    required this.password,
    required this.userId,
  });
}
