import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagram/Services/firebase_auth_service.dart';
import 'package:instagram/features/Authentication/Presentation/forget_password_screen.dart';
import 'package:instagram/features/Authentication/Presentation/login_screen.dart';
import 'package:instagram/features/Authentication/Presentation/signup_screen.dart';
import 'package:instagram/features/Home/home_screen.dart';
import 'package:instagram/features/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'features/Authentication/logics/auth_cubit.dart';
import 'features/Authentication/data/repositort/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AuthCubit(authRepository: AuthRepository(FirebaseAuthService())),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram',
        theme: ThemeData(primarySwatch: Colors.blue),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        initialRoute: SplashScreen.routeName,
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
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
      default:
        return null;
    }
  }
}
