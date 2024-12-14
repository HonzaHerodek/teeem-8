import '../../../core/errors/app_exception.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? username;
  final AppException? error;

  const AuthState({
    required this.status,
    this.userId,
    this.username,
    this.error,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        userId = null,
        username = null,
        error = null;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? username,
    AppException? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      error: error ?? this.error,
    );
  }

  // Getters for common state checks
  bool get isInitial => status == AuthStatus.initial;
  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isError => status == AuthStatus.error;
  bool get hasError => error != null;
  bool get isAuthenticating => status == AuthStatus.loading;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          userId == other.userId &&
          username == other.username &&
          error == other.error;

  @override
  int get hashCode =>
      status.hashCode ^ userId.hashCode ^ username.hashCode ^ error.hashCode;

  @override
  String toString() {
    return 'AuthState{status: $status, userId: $userId, username: $username, error: $error}';
  }
}
