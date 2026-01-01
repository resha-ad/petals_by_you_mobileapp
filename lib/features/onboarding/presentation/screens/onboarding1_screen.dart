import 'package:flutter/material.dart';
import 'package:sprint1_project/features/onboarding/presentation/screens/onboarding2_screen.dart';

class Onboard1 extends StatelessWidget {
  const Onboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_florist, size: 200, color: Colors.pinkAccent),

                const SizedBox(height: 30),

                const Text(
                  "Create Your Dream Bouquet",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Choose flowers, colors, wrapping and more — fully customizable.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Onboard2()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(248, 187, 208, 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
