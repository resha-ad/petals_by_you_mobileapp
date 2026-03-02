import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/favorites/presentation/view_model/favorites_view_model.dart';

/// A self-contained heart icon button.
/// Reads and writes to [favoritesViewModelProvider] automatically.
///
/// Usage:
/// ```dart
/// FavoriteButton(refId: item.id)
/// FavoriteButton(refId: item.id, size: 20, padding: EdgeInsets.all(8))
/// ```
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

    final btn = GestureDetector(
      onTap: isPending
          ? null
          : () => ref
                .read(favoritesViewModelProvider.notifier)
                .toggleFavorite(refId: refId, type: type),
      child: withBackground
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: padding ?? const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isFav
                    ? Colors.red.shade50
                    : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
