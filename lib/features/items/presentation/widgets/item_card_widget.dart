import 'package:flutter/material.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';
import 'package:sprint1_project/features/items/presentation/screens/item_detail_screen.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF1B4332);
const _kAccent = Color(0xFFD4A853);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

// ─────────────────────────────────────────────────────────────────────────────
// Grid card
// Pass isOffline=true when the data was read from Hive (isFromCache).
// The image area then shows a local asset placeholder immediately instead of
// attempting (and failing) to load the network URL.
// ─────────────────────────────────────────────────────────────────────────────
class ItemCard extends StatefulWidget {
  final ItemEntity item;
  final bool isOffline;
  final VoidCallback? onFavoriteTap;

  const ItemCard({
    super.key,
    required this.item,
    this.isOffline = false,
    this.onFavoriteTap,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isFav = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id)),
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
            // ── Image ──────────────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: SizedBox.expand(child: _buildImage(item)),
                  ),
                  // Badges
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.isFeatured)
                          _Badge(
                            label: 'Featured',
                            bg: _kPrimary,
                            fg: Colors.white,
                          ),
                        if (item.hasDiscount) ...[
                          const SizedBox(height: 4),
                          _Badge(
                            label:
                                '-${(((item.price - item.effectivePrice) / item.price) * 100).round()}%',
                            bg: _kAccent,
                            fg: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Offline indicator over image
                  if (widget.isOffline)
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
                  // Favourite button
                  if (!widget.isOffline)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isFav = !_isFav);
                          widget.onFavoriteTap?.call();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _isFav
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
                          child: Icon(
                            _isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: _isFav ? Colors.red : _kTextMid,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name — shimmer-like grey box when offline
                    widget.isOffline
                        ? _OfflinePlaceholderLine(
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
                    // Price row
                    widget.isOffline
                        ? _OfflinePlaceholderLine(width: 80, height: 15)
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
                                _StockTag(label: 'Sold out', color: Colors.red)
                              else if (item.stock <= 5)
                                _StockTag(
                                  label: 'Only ${item.stock}',
                                  color: Colors.orange,
                                ),
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

  Widget _buildImage(ItemEntity item) {
    // Offline → always show local asset placeholder, never hit the network
    if (widget.isOffline || item.primaryImage == null) {
      return _ImagePlaceholder(isOffline: widget.isOffline);
    }
    return Image.network(
      ApiEndpoints.fullImageUrl(item.primaryImage!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ImagePlaceholder(isOffline: false),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List tile — used in search results
// ─────────────────────────────────────────────────────────────────────────────
class ItemListTile extends StatefulWidget {
  final ItemEntity item;
  final bool isOffline;
  final VoidCallback? onFavoriteTap;

  const ItemListTile({
    super.key,
    required this.item,
    this.isOffline = false,
    this.onFavoriteTap,
  });

  @override
  State<ItemListTile> createState() => _ItemListTileState();
}

class _ItemListTileState extends State<ItemListTile> {
  bool _isFav = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: widget.isOffline
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailScreen(itemId: item.id),
              ),
            ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: SizedBox(
                width: 90,
                height: 90,
                child: widget.isOffline || item.primaryImage == null
                    ? _ImagePlaceholder(isOffline: widget.isOffline)
                    : Image.network(
                        ApiEndpoints.fullImageUrl(item.primaryImage!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _ImagePlaceholder(isOffline: false),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: widget.isOffline
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OfflinePlaceholderLine(width: 60, height: 10),
                          const SizedBox(height: 6),
                          _OfflinePlaceholderLine(
                            width: double.infinity,
                            height: 13,
                          ),
                          const SizedBox(height: 4),
                          _OfflinePlaceholderLine(width: 120, height: 13),
                          const SizedBox(height: 8),
                          _OfflinePlaceholderLine(width: 80, height: 15),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.category != null)
                            Text(
                              item.category!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: _kTextLight,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kTextDark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Rs. ${item.effectivePrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _kPrimary,
                                ),
                              ),
                              if (item.hasDiscount) ...[
                                const SizedBox(width: 6),
                                Text(
                                  'Rs. ${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _kTextLight,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
              ),
            ),

            if (!widget.isOffline)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isFav = !_isFav);
                    widget.onFavoriteTap?.call();
                  },
                  child: Icon(
                    _isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 22,
                    color: _isFav ? Colors.red : _kTextLight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Shows a local asset when offline, a flower icon when no image available.
class _ImagePlaceholder extends StatelessWidget {
  final bool isOffline;
  const _ImagePlaceholder({required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F4EE),
      child: Center(
        child: isOffline
            // Use local asset when offline so nothing loads from the network
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

/// A muted grey rectangle — skeleton/placeholder line for offline cards.
class _OfflinePlaceholderLine extends StatelessWidget {
  final double width;
  final double height;
  const _OfflinePlaceholderLine({required this.width, required this.height});

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

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StockTag extends StatelessWidget {
  final String label;
  final Color color;
  const _StockTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
