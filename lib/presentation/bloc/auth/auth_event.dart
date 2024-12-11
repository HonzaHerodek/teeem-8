abstract class AuthEvent {
  const AuthEvent();
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.username,
  });
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({required this.isAuthenticated});
}
