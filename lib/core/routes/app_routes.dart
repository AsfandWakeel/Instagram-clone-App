import 'package:flutter/material.dart';
import 'package:instagram/features/splash/splash_screen.dart';
import 'package:instagram/features/Authentication/Presentation/login_screen.dart';
import 'package:instagram/features/Authentication/Presentation/signup_screen.dart';
import 'package:instagram/features/Authentication/Presentation/forget_password_screen.dart';
import 'package:instagram/features/Home/home_screen.dart';
import 'package:instagram/features/Feed/presentation/feed_screen.dart';

class AppRoutes {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case SignupScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case ForgotPasswordScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case HomeScreen.routeName:
        final currentUserId = settings.arguments as String?;
        if (currentUserId != null) {
          return MaterialPageRoute(
            builder: (_) => HomeScreen(currentUserId: currentUserId),
          );
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case FeedScreen.routeName:
        final currentUserId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => FeedScreen(currentUserId: currentUserId),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
