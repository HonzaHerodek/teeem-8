import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/di/injection.dart';
import 'presentation/app.dart';

// Debug flag for development mode
const bool kIsDebug = kDebugMode;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  initializeDependencies();

  runApp(const App());
}
