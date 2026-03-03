import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF1B4332);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextLight = Color(0xFF9E9E9E);

class SharedOfflineBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const SharedOfflineBanner({
    super.key,
    this.message = "You're offline — showing cached data",
    required this.onRetry,
  });

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
          const Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFFB08800)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
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

class SharedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const SharedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F4EE),
                borderRadius: BorderRadius.circular(24)),
            child: Icon(icon, size: 40, color: const Color(0xFF52B788)),
          ),
          const SizedBox(height: 18),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _kTextLight)),
        ],
      ),
    );
  }
}

class SharedErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback onRetry;
  const SharedErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F4EE),
                borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.wifi_off_rounded,
                size: 36, color: Color(0xFF52B788)),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark)),
          const SizedBox(height: 6),
          Text(message ?? 'Check your connection and try again',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _kTextLight)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('Try Again',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
