import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF1B4332);

class CartOfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const CartOfflineBanner({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD970)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 16, color: Color(0xFFB08800)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text("You're offline — showing saved cart",
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A5E00),
                    fontWeight: FontWeight.w500)),
          ),
          GestureDetector(
            onTap: onRetry,
            child: const Text('Retry',
                style: TextStyle(
                    fontSize: 12,
                    color: _kPrimary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
