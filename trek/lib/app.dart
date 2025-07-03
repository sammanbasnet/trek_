import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/view/login_page.dart';
import 'features/auth/presentation/view/signup_page.dart';
import 'features/home/presentation/view/dashboard_page.dart';
import 'features/home/presentation/view/splash_screen.dart';
import 'features/profile/presentation/view/profile_page.dart';

class TrekApp extends StatelessWidget {
  const TrekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository: sl<AuthRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Trek Mobile',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Opensans Regular',
        ),
        home: const SplashScreen(),
        routes: {
          '/signup': (context) => const SignUpPage(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/profile': (context) => const ProfilePage(),
        },
      ),
    );
  }
}