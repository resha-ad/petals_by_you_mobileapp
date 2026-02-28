import 'package:flutter/material.dart';
import 'package:sprint1_project/app/themes/app_theme.dart';
import 'package:sprint1_project/features/splash/presentation/screens/splash_screen.dart';
import 'package:sprint1_project/features/auth/presentation/screens/login_screen.dart';
import 'package:sprint1_project/features/dashboard/presentation/screens/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Petals By You',
      theme: AppTheme.lightTheme, // your custom theme
      initialRoute: '/', // start from splash
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
