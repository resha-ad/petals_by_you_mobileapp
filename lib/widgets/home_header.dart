import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(252, 228, 236, 1),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          "Let’s find your flower",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
