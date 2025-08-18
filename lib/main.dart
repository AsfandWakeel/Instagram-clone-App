import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagram/features/Authentication/Presentation/forget_password_screen.dart';
import 'package:instagram/features/Authentication/Presentation/login_screen.dart';
import 'package:instagram/features/Authentication/Presentation/signup_screen.dart';
import 'package:instagram/features/Home/home_screen.dart';
import 'package:instagram/features/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'features/Authentication/logics/auth_cubit.dart';
import 'features/Authentication/data/models/Repositories/auth_repository.dart';

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
      create: (_) => AuthCubit(authRepository: AuthRepository()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram',
        theme: ThemeData(primarySwatch: Colors.blue),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,

        initialRoute: '/splash',

        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/forgotPassword': (_) => const ForgotPasswordScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
