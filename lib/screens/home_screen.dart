import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
      appBar: AppBar(title: const Text("Home"), centerTitle: true),
      body: const Center(
        child: Text(
          "Welcome to Home Screen!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
