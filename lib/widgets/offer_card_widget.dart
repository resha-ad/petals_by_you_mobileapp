import 'package:flutter/material.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromRGBO(252, 228, 236, 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Mothers Day",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Get 20% discount on all bouquets",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.card_giftcard, size: 60, color: Colors.pink),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
