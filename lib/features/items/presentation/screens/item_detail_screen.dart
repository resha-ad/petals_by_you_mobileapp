// lib/features/items/presentation/screens/item_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sprint1_project/features/favorites/presentation/widgets/favorite_button_widget.dart';
import 'package:sprint1_project/features/items/presentation/state/item_state.dart';
import 'package:sprint1_project/features/items/presentation/view_model/item_view_model.dart';

const _kPrimary = Color(0xFF1B4332);
const _kAccent = Color(0xFFD4A853);
const _kBackground = Color(0xFFF9F6F0);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itemViewModelProvider.notifier).getItemById(widget.itemId);
    });
  }

  Future<void> _addToCart() async {
    setState(() => _addingToCart = true);

    final success = await ref
        .read(cartViewModelProvider.notifier)
        .addProduct(itemId: widget.itemId, quantity: _quantity);

    if (!mounted) return;
    setState(() => _addingToCart = false);

    if (success) {
      // Reset quantity to 1 after adding, so user doesn't accidentally add more when they return to the screen
      setState(() => _quantity = 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('💐  Added to cart!'),
          backgroundColor: _kPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      ref.read(cartViewModelProvider.notifier).clearError();
    } else {
      final errMsg =
          ref.read(cartViewModelProvider).errorMessage ?? 'Failed to add';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('⚠️  '),
              Expanded(child: Text(errMsg)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      ref.read(cartViewModelProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemViewModelProvider);
    final item = itemState.selectedItem;

    if (itemState.status == ItemStatus.loading) {
      return Scaffold(
        backgroundColor: _kBackground,
        body: const Center(
          child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2),
        ),
      );
    }

    if (item == null || itemState.status == ItemStatus.error) {
      return Scaffold(
        backgroundColor: _kBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: _kTextDark),
        ),
        body: Center(
          child: Text(
            itemState.errorMessage ?? 'Item not found',
            style: const TextStyle(color: _kTextMid, fontSize: 14),
          ),
        ),
      );
    }

    final imageCount = item.images.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kBackground,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── Image gallery ──────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 360,
                  pinned: true,
                  backgroundColor: const Color(0xFF0D2B1E),
                  automaticallyImplyLeading: false,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageCount > 0
                            ? PageView.builder(
                                itemCount: imageCount,
                                onPageChanged: (i) =>
                                    setState(() => _selectedImageIndex = i),
                                itemBuilder: (_, i) => Image.network(
                                  ApiEndpoints.fullImageUrl(item.images[i]),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, ___) => _imageFallback(),
                                ),
                              )
                            : _imageFallback(),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 120,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Color(0xCC0D2B1E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        if (imageCount > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                imageCount,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: _selectedImageIndex == i ? 22 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _selectedImageIndex == i
                                        ? _kAccent
                                        : Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Content ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: _kBackground,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDD8CF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badges
                              Row(
                                children: [
                                  if (item.category != null)
                                    _Chip(
                                      label: item.category!,
                                      bg: const Color(0xFFE8F4EE),
                                      fg: _kPrimary,
                                    ),
                                  if (item.isFeatured) ...[
                                    const SizedBox(width: 8),
                                    _Chip(
                                      label: '⭐ Featured',
                                      bg: const Color(0xFFFFF3D4),
                                      fg: const Color(0xFF7A5E00),
                                    ),
                                  ],
                                  if (!item.isAvailable) ...[
                                    const SizedBox(width: 8),
                                    _Chip(
                                      label: 'Unavailable',
                                      bg: const Color(0xFFFFEEEE),
                                      fg: Colors.red.shade700,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 14),

                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: _kTextDark,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Price
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rs. ${item.effectivePrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: _kPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  if (item.hasDiscount) ...[
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Rs. ${item.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: _kTextLight,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '-${(((item.price - item.effectivePrice) / item.price) * 100).round()}% OFF',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 20),
                              const Divider(
                                color: Color(0xFFEEE8DE),
                                height: 1,
                              ),
                              const SizedBox(height: 20),

                              // Detail chips
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _DetailChip(
                                    icon: '📦',
                                    label: item.stock > 0
                                        ? '${item.stock} in stock'
                                        : 'Out of stock',
                                    urgent: item.stock == 0,
                                    low: item.stock > 0 && item.stock <= 5,
                                  ),
                                  if (item.preparationTime != null)
                                    _DetailChip(
                                      icon: '⏱️',
                                      label: '${item.preparationTime} min prep',
                                    ),
                                  if (item.deliveryType != null)
                                    _DetailChip(
                                      icon: '🚚',
                                      label: item.deliveryType!,
                                    ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              const Text(
                                'About this bouquet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _kTextDark,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _kTextMid,
                                  height: 1.7,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Quantity selector
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _kSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEEE8DE),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Quantity',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _kTextDark,
                                      ),
                                    ),
                                    const Spacer(),
                                    _QtyButton(
                                      icon: Icons.remove_rounded,
                                      onTap: () {
                                        if (_quantity > 1) {
                                          setState(() => _quantity--);
                                        }
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: _kTextDark,
                                        ),
                                      ),
                                    ),
                                    _QtyButton(
                                      icon: Icons.add_rounded,
                                      onTap: () {
                                        if (_quantity < item.stock) {
                                          setState(() => _quantity++);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Floating nav (back + favourite) ────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FloatBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  // Real favourite toggle
                  FavoriteButton(
                    refId: widget.itemId,
                    type: 'product',
                    size: 20,
                    withBackground: true,
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),

            // ── Bottom add-to-cart bar ──────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  MediaQuery.of(context).padding.bottom + 14,
                ),
                decoration: BoxDecoration(
                  color: _kSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 12, color: _kTextLight),
                        ),
                        Text(
                          'Rs. ${(item.effectivePrice * _quantity).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _kPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: (item.stock == 0 || _addingToCart)
                            ? null
                            : _addToCart,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 52,
                          decoration: BoxDecoration(
                            color: item.stock == 0
                                ? Colors.grey.shade300
                                : _kPrimary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: item.stock > 0
                                ? [
                                    BoxShadow(
                                      color: _kPrimary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: _addingToCart
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        color: item.stock == 0
                                            ? Colors.grey.shade500
                                            : Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.stock == 0
                                            ? 'Out of Stock'
                                            : 'Add to Bag',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: item.stock == 0
                                              ? Colors.grey.shade500
                                              : Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
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

  Widget _imageFallback() => Container(
    color: const Color(0xFF0D2B1E),
    child: const Center(child: Text('🌸', style: TextStyle(fontSize: 80))),
  );
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool urgent;
  final bool low;
  const _DetailChip({
    required this.icon,
    required this.label,
    this.urgent = false,
    this.low = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = urgent
        ? Colors.red.shade50
        : low
        ? Colors.orange.shade50
        : const Color(0xFFF0EDE8);
    final fg = urgent
        ? Colors.red.shade700
        : low
        ? Colors.orange.shade700
        : _kTextMid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _FloatBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: _kTextDark, size: 18),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4EE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: _kPrimary),
      ),
    );
  }
}
