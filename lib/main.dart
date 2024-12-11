import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize Firebase if not in debug mode
  if (!kIsDebug) {
    await Firebase.initializeApp();
  }

  // Initialize dependencies
  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
