import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/feed/feed_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/create_post/create_post_screen.dart';
import '../../presentation/screens/debug/traits_test_screen.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToAndReplace(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToAndClearStack(String routeName,
      {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String feed = '/feed';
  static const String createPost = '/create-post';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String postDetails = '/post-details';
  static const String userProfile = '/user-profile';
  static const String traitsTest = '/traits-test';
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.traitsTest:
      return MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const TraitsTestScreen(),
        settings: settings,
      );
    case AppRoutes.splash:
      return MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const SplashScreen(),
        settings: settings,
      );
    case AppRoutes.login:
      return MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const LoginScreen(),
        settings: settings,
      );
    case AppRoutes.signup:
      return MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const SignupScreen(),
        settings: settings,
      );
    case AppRoutes.feed:
      return MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const FeedScreen(),
        settings: settings,
      );
    case AppRoutes.profile:
      return MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const ProfileScreen(),
        settings: settings,
      );
    case AppRoutes.createPost:
      return MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const CreatePostScreen(),
        settings: settings,
      );
    default:
      return MaterialPageRoute<Widget>(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}
