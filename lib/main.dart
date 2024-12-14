import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'core/di/injection.dart';
import 'presentation/app.dart';

// Debug flag for development mode
const bool kIsDebug = kDebugMode;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide system UI completely
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // Initialize dependencies
  initializeDependencies();

  runApp(const App());
}
