import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:instagram/features/Authentication/data/repository/auth_repository.dart';
import 'package:instagram/features/Authentication/logics/auth_cubit.dart';
import 'package:instagram/features/Post/logics/post_cubit.dart';
import 'package:instagram/features/Post/Data/post_repository.dart';
import 'package:instagram/features/Feed/logics/feed_cubit.dart';
import 'package:instagram/Services/firebase_auth_service.dart';
import 'package:instagram/core/theme/app_theme.dart';
import 'package:instagram/core/routes/app_routes.dart';
import 'package:instagram/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final postRepository = PostRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthCubit(authRepository: AuthRepository(FirebaseAuthService())),
        ),
        BlocProvider(create: (_) => PostCubit(postRepository)),
        BlocProvider(create: (_) => FeedCubit(postRepository)), // FeedCubit
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram',
        theme: AppTheme.lightTheme,
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        initialRoute: SplashScreen.routeName,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
