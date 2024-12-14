class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() =>
      'AppException: $message${code != null ? ' ($code)' : ''}';
}

class NetworkException extends AppException {
  NetworkException([String? message])
      : super(message ?? 'A network error occurred');
}

class AuthException extends AppException {
  AuthException([String? message]) : super(message ?? 'Authentication failed');
}

class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(message ?? 'The requested resource was not found');
}

class ValidationException extends AppException {
  ValidationException([String? message])
      : super(message ?? 'Invalid data provided');
}

class ServerException extends AppException {
  ServerException([String? message])
      : super(message ?? 'A server error occurred');
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message])
      : super(message ?? 'Unauthorized access');
}

class ForbiddenException extends AppException {
  ForbiddenException([String? message]) : super(message ?? 'Access forbidden');
}

class TimeoutException extends AppException {
  TimeoutException([String? message])
      : super(message ?? 'The operation timed out');
}

class CacheException extends AppException {
  CacheException([String? message])
      : super(message ?? 'A cache error occurred');
}

class ParseException extends AppException {
  ParseException([String? message]) : super(message ?? 'Failed to parse data');
}

class StorageException extends AppException {
  StorageException([String? message])
      : super(message ?? 'A storage error occurred');
}
