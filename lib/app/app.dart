import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/app/themes/app_theme.dart';
import 'package:sprint1_project/core/providers/app_theme_provider.dart';
import 'package:sprint1_project/features/splash/presentation/screens/splash_screen.dart';
import 'package:sprint1_project/features/auth/presentation/screens/login_screen.dart';
import 'package:sprint1_project/features/dashboard/presentation/screens/dashboard_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Petals By You',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
