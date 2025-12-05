import 'package:flutter/material.dart';
import 'package:sprint1_project/screens/onboarding1_screen.dart';
import 'package:sprint1_project/screens/onboarding2_screen.dart';
import 'package:sprint1_project/screens/onboarding3_screen.dart';
import 'package:sprint1_project/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Onboard3());
  }
}
