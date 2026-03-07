import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/favorites/presentation/view_model/favorites_view_model.dart';

class FavoriteButton extends ConsumerWidget {
  final String refId;
  final String type;
  final double size;
  final EdgeInsetsGeometry? padding;

  /// If true, renders on a white circular background (card style).
  final bool withBackground;

  const FavoriteButton({
    super.key,
    required this.refId,
    this.type = 'product',
    this.size = 18,
    this.padding,
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesViewModelProvider);
    final isFav = state.isFavorite(refId);
    final isPending = state.isPending(refId);

    // Check connectivity — disable the button entirely when offline
    final networkInfo = ref.read(networkInfoProvider);

    Widget icon = isPending
        ? SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: isFav ? Colors.red : const Color(0xFF1B4332),
            ),
          )
        : Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: size,
            color: isFav ? Colors.red : const Color(0xFF5C5C5C),
          );

    Future<void> onTap() async {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'You\'re offline. Connect to manage favourites.',
            ),
            backgroundColor: const Color(0xFF1B4332),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
      ref
          .read(favoritesViewModelProvider.notifier)
          .toggleFavorite(refId: refId, type: type);
    }

    final btn = GestureDetector(
      onTap: isPending ? null : onTap,
      child: withBackground
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: padding ?? const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isFav
                    ? Colors.red.shade50
                    : Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: icon,
            )
          : Padding(padding: padding ?? const EdgeInsets.all(4), child: icon),
    );

    return btn;
  }
}
