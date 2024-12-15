import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/logger_service.dart';

/// Base class for all BLoCs in the application
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  final ConnectivityService _connectivityService;
  final LoggerService _logger;
  StreamSubscription<NetworkStatus>? _connectivitySubscription;

  BaseBloc({
    required State initialState,
    required ConnectivityService connectivityService,
    LoggerService? logger,
  })  : _connectivityService = connectivityService,
        _logger = logger ?? LoggerService(),
        super(initialState) {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.status.listen(
      (status) => onNetworkStatusChanged(status),
      onError: (error) {
        _logger.e('Network status monitoring error', error: error);
      },
    );
  }

  /// Called when network status changes
  void onNetworkStatusChanged(NetworkStatus status) {
    _logger.i('Network status changed', data: {'status': status.toString()});
  }

  /// Check if device is currently online
  bool get isOnline => _connectivityService.isOnline;

  /// Current network status
  NetworkStatus get networkStatus => _connectivityService.currentStatus;

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    await super.close();
  }

  /// Log state changes in debug mode
  @override
  void onChange(Change<State> change) {
    super.onChange(change);
    _logger.d(
      'State changed in ${runtimeType.toString()}',
      data: {
        'from': change.currentState.toString(),
        'to': change.nextState.toString(),
      },
    );
  }

  /// Log errors in debug mode
  @override
  void onError(Object error, StackTrace stackTrace) {
    _logger.e(
      'Error in ${runtimeType.toString()}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(error, stackTrace);
  }
}
