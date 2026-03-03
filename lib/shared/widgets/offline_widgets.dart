import 'package:flutter/material.dart';

/// Reusable image placeholder — shows a flower icon, or an asset image when
class OfflineImagePlaceholder extends StatelessWidget {
  final bool isOffline;
  const OfflineImagePlaceholder({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F4EE),
      child: Center(
        child: isOffline
            ? Image.asset(
                'assets/images/placeholder_flower.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_florist_outlined,
                  size: 40,
                  color: Color(0xFF52B788),
                ),
              )
            : const Icon(
                Icons.local_florist_outlined,
                size: 40,
                color: Color(0xFF52B788),
              ),
      ),
    );
  }
}

/// Reusable shimmer-style placeholder line for offline card skeletons.
class OfflinePlaceholderLine extends StatelessWidget {
  final double width;
  final double height;
  const OfflinePlaceholderLine({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
