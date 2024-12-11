import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  bool _isEnabled = true;
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  void enable() => _isEnabled = true;
  void disable() => _isEnabled = false;
  void setMinLevel(LogLevel level) => _minLevel = level;

  void _log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!_isEnabled || level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final logMessage = '[$timestamp] $levelStr: $message';
    final dataStr = data != null ? '\nData: $data' : '';

    if (kDebugMode) {
      // In debug mode, use print statements
      print(logMessage + dataStr);
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    } else {
      // In release mode, use dart:developer log
      developer.log(
        logMessage + dataStr,
        time: DateTime.now(),
        level: _getLevelNumber(level),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  int _getLevelNumber(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  // Debug level logging
  void d(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.debug, message,
        error: error, stackTrace: stackTrace, data: data);
  }

  // Info level logging
  void i(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.info, message,
        error: error, stackTrace: stackTrace, data: data);
  }

  // Warning level logging
  void w(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.warning, message,
        error: error, stackTrace: stackTrace, data: data);
  }

  // Error level logging
  void e(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.error, message,
        error: error, stackTrace: stackTrace, data: data);
  }

  // Log method call
  void logMethodCall(
    String methodName, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
  }) {
    if (!_isEnabled || LogLevel.debug.index < _minLevel.index) return;

    final paramsStr = params?.toString() ?? '';
    d(
      'Method Call: $methodName${paramsStr.isNotEmpty ? ' - Params: $paramsStr' : ''}',
      data: data,
    );
  }

  // Log API call
  void logApiCall(
    String endpoint,
    String method, {
    Map<String, dynamic>? params,
    dynamic response,
    Map<String, dynamic>? data,
  }) {
    if (!_isEnabled || LogLevel.debug.index < _minLevel.index) return;

    final paramsStr = params?.toString() ?? '';
    final responseStr = response?.toString() ?? '';
    d(
      'API Call: $method $endpoint${paramsStr.isNotEmpty ? '\nParams: $paramsStr' : ''}${responseStr.isNotEmpty ? '\nResponse: $responseStr' : ''}',
      data: data,
    );
  }

  // Log user action
  void logUserAction(
    String action, {
    Map<String, dynamic>? actionData,
    Map<String, dynamic>? data,
  }) {
    if (!_isEnabled || LogLevel.info.index < _minLevel.index) return;

    final dataStr = actionData?.toString() ?? '';
    i(
      'User Action: $action${dataStr.isNotEmpty ? ' - Data: $dataStr' : ''}',
      data: data,
    );
  }

  // Log error with context
  void logError(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    e('Error in $context', error: error, stackTrace: stackTrace, data: data);
  }

  // Log performance metric
  void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? data,
  }) {
    if (!_isEnabled || LogLevel.debug.index < _minLevel.index) return;

    d(
      'Performance: $operation took ${duration.inMilliseconds}ms',
      data: data,
    );
  }

  // Log app lifecycle event
  void logLifecycleEvent(
    String event, {
    Map<String, dynamic>? data,
  }) {
    i('Lifecycle Event: $event', data: data);
  }

  // Log navigation
  void logNavigation(
    String from,
    String to, {
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? data,
  }) {
    if (!_isEnabled || LogLevel.debug.index < _minLevel.index) return;

    final argsStr = arguments?.toString() ?? '';
    d(
      'Navigation: $from → $to${argsStr.isNotEmpty ? ' - Arguments: $argsStr' : ''}',
      data: data,
    );
  }

  // Log state change
  void logStateChange(
    String bloc,
    String event,
    String fromState,
    String toState, {
    Map<String, dynamic>? data,
  }) {
    if (!_isEnabled || LogLevel.debug.index < _minLevel.index) return;

    d(
      'State Change in $bloc\nEvent: $event\nFrom: $fromState\nTo: $toState',
      data: data,
    );
  }
}

// Global instance
final logger = LoggerService();
