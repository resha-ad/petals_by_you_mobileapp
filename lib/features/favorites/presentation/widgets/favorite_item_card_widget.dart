import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/presentation/view_model/favorites_view_model.dart';
import 'package:sprint1_project/features/items/presentation/screens/item_detail_screen.dart';
import 'package:sprint1_project/shared/widgets/offline_widgets.dart';

const _kPrimary = Color(0xFF1B4332);
const _kAccent = Color(0xFFD4A853);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextLight = Color(0xFF9E9E9E);

class FavoriteItemCard extends ConsumerWidget {
  final FavoriteEntity favorite;

  /// When true the card shows offline placeholders and disables the remove btn.
  final bool isOffline;

  const FavoriteItemCard({
    super.key,
    required this.favorite,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = favorite.refItem;
    if (item == null) return const SizedBox.shrink();

    final state = ref.watch(favoritesViewModelProvider);
    final isPending = state.isPending(favorite.refId);

    return GestureDetector(
      onTap: isOffline
          ? null // disable navigation when offline (no fresh data)
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailScreen(itemId: favorite.refId),
              ),
            ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: SizedBox.expand(
                      child: isOffline
                          // Reuse the exact same placeholder logic as ItemCard
                          ? OfflineImagePlaceholder(isOffline: true)
                          : item.primaryImage != null
                          ? Image.network(
                              ApiEndpoints.fullImageUrl(item.primaryImage!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  OfflineImagePlaceholder(isOffline: false),
                            )
                          : OfflineImagePlaceholder(isOffline: false),
                    ),
                  ),
                  // Discount badge
                  if (!isOffline && item.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _kAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${(((item.price - item.effectivePrice) / item.price) * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  // Remove button — hidden when offline
                  if (!isOffline)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: isPending
                            ? null
                            : () => ref
                                  .read(favoritesViewModelProvider.notifier)
                                  .removeFavorite(favorite.refId),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: isPending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    color: Colors.red,
                                  ),
                                )
                              : const Icon(
                                  Icons.favorite_rounded,
                                  size: 16,
                                  color: Colors.red,
                                ),
                        ),
                      ),
                    ),
                  // Offline indicator badge
                  if (isOffline)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ────────────────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name — placeholder when offline
                    isOffline
                        ? const OfflinePlaceholderLine(
                            width: double.infinity,
                            height: 13,
                          )
                        : Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kTextDark,
                              height: 1.3,
                            ),
                          ),
                    // Price row — placeholder when offline
                    isOffline
                        ? const OfflinePlaceholderLine(width: 80, height: 15)
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.hasDiscount)
                                      Text(
                                        'Rs. ${item.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: _kTextLight,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    Text(
                                      'Rs. ${item.effectivePrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: _kPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.stock == 0)
                                _stockTag('Sold out', Colors.red)
                              else if (item.stock <= 5)
                                _stockTag('Only ${item.stock}', Colors.orange),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stockTag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
    ),
  );
}
