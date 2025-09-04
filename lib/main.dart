import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/services/notification_services.dart';
import 'package:instagram/services/fcm_service.dart';
import 'package:instagram/services/firebase_auth_service.dart';
import 'package:instagram/services/firebase_storage.dart';
import 'package:instagram/features/Post/Data/post_repository.dart';
import 'package:instagram/features/Authentication/logics/auth_cubit.dart';
import 'package:instagram/features/Authentication/data/repository/auth_repository.dart';
import 'package:instagram/features/Feed/data/feed_repository.dart';
import 'package:instagram/features/Post/logics/post_cubit.dart';
import 'package:instagram/features/Feed/logics/feed_cubit.dart';
import 'package:instagram/features/notifications/data/notification_repository.dart';
import 'package:instagram/features/notifications/logics/notification_cubit.dart';
import 'package:instagram/features/Profile/logics/profile_cubit.dart';
import 'package:instagram/features/Profile/Data/profile_repository.dart';
import 'package:instagram/core/routes/app_routes.dart';
import 'package:instagram/core/theme/app_theme.dart';
import 'package:instagram/features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FcmService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) =>
              AuthRepository(context.read<FirebaseAuthService>()),
        ),
        RepositoryProvider<PostRepository>(create: (_) => PostRepository()),
        RepositoryProvider<FeedRepository>(create: (_) => FeedRepository()),
        RepositoryProvider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (context) =>
              NotificationRepository(context.read<NotificationService>()),
        ),
        RepositoryProvider<FirebaseStorageService>(
          create: (_) => FirebaseStorageService.instance,
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(
            firestore: FirebaseFirestore.instance,
            storage: context.read<FirebaseStorageService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<PostCubit>(
            create: (context) => PostCubit(context.read<PostRepository>()),
          ),
          BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit(
              notificationRepository: context.read<NotificationRepository>(),
            ),
          ),
          BlocProvider<FeedCubit>(
            create: (context) => FeedCubit(
              context.read<FeedRepository>(),
              context.read<NotificationCubit>(),
              context.read<NotificationRepository>(),
            ),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              repository: context.read<ProfileRepository>(),
              currentUserId: FirebaseAuth.instance.currentUser?.uid ?? "",
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Instagram Clone',
          theme: AppTheme.lightTheme,
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          initialRoute: SplashScreen.routeName,
          onGenerateRoute: AppRoutes.generateRoute,
        ),
      ),
    );
  }
}
