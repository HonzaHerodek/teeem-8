import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/injection.dart';
import '../core/navigation/navigation_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/user_repository.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = getIt<NavigationService>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
            userRepository: getIt<UserRepository>(),
          )..add(const AuthStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: navigationService.navigatorKey,
        initialRoute: AppRoutes.traitsTest, // Changed for testing
        onGenerateRoute: generateRoute,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
      ),
    );
  }
}
