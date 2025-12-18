import 'package:flutter/material.dart';
import 'package:sprint1_project/screens/dashboard_screen.dart';
import 'package:sprint1_project/screens/splash_screen.dart';
import 'package:sprint1_project/themes/app_theme.dart';

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
