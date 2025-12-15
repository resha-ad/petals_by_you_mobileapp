import 'package:flutter/material.dart';
import 'package:sprint1_project/widgets/home_header_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: const [HomeHeader()]),
    );
  }
}
