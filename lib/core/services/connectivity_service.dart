import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../errors/app_exception.dart';
import 'logger_service.dart';

/// Network connection status
enum NetworkStatus {
  online,
  offline,
}

/// Service to monitor and manage network connectivity
class ConnectivityService {
  final Connectivity _connectivity;
  final LoggerService _logger;
  final _connectivityController = StreamController<NetworkStatus>.broadcast();
  bool _isInitialized = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  NetworkStatus _lastStatus = NetworkStatus.offline;

  ConnectivityService({
    Connectivity? connectivity,
    LoggerService? logger,
  })  : _connectivity = connectivity ?? Connectivity(),
        _logger = logger ?? LoggerService();

  /// Stream of network status
  Stream<NetworkStatus> get status => _connectivityController.stream;

  /// Current network status
  NetworkStatus get currentStatus => _lastStatus;

  /// Check if device is currently online
  bool get isOnline => _lastStatus == NetworkStatus.online;

  /// Initialize the connectivity monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await checkConnectivity();
      _subscription = _connectivity.onConnectivityChanged.listen((results) {
        _handleConnectivityChange(results.first);
      });
      _isInitialized = true;
    } catch (e) {
      _logger.e('Failed to initialize connectivity service', error: e);
      throw AppException('Failed to initialize connectivity service');
    }
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = _isConnected(results.first);
      _updateStatus(isConnected);
      return isConnected;
    } catch (e) {
      _logger.e('Failed to check connectivity', error: e);
      _updateStatus(false);
      return false;
    }
  }

  /// Handle connectivity change events
  void _handleConnectivityChange(ConnectivityResult result) {
    final isConnected = _isConnected(result);
    _updateStatus(isConnected);

    _logger.i(
      'Connectivity changed',
      data: {
        'status': result.toString(),
        'isConnected': isConnected,
      },
    );
  }

  /// Update the current network status
  void _updateStatus(bool isConnected) {
    _lastStatus = isConnected ? NetworkStatus.online : NetworkStatus.offline;
    _connectivityController.add(_lastStatus);
  }

  /// Convert ConnectivityResult to boolean connection status
  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
    _isInitialized = false;
  }
}
