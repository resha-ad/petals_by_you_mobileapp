import 'package:flutter/material.dart';
import 'package:sprint1_project/features/app/themes/app_theme.dart';
import 'package:sprint1_project/features/splash/presentation/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
