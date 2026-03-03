import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/presentation/state/cart_state.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sprint1_project/features/orders/presentation/screen/place_order_screen.dart';

const _kPrimary = Color(0xFF1B4332);
const _kAccent = Color(0xFFD4A853);
const _kBackground = Color(0xFFF9F6F0);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartViewModelProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartViewModelProvider);
    final isOffline = state.isFromCache;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kBackground,
        body: RefreshIndicator(
          color: _kPrimary,
          backgroundColor: _kSurface,
          onRefresh: () => ref.read(cartViewModelProvider.notifier).loadCart(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              _CartHeader(
                itemCount: state.itemCount,
                onClear: state.isEmpty || isOffline
                    ? null
                    : () => _confirmClear(context),
              ),

              // ── Offline banner ───────────────────────────────────────────
              if (isOffline)
                SliverToBoxAdapter(
                  child: _OfflineBanner(
                    onRetry: () =>
                        ref.read(cartViewModelProvider.notifier).loadCart(),
                  ),
                ),

              // ── Body ────────────────────────────────────────────────────
              if (state.status == CartStatus.loading && state.cart == null)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _kPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (state.status == CartStatus.error && state.cart == null)
                SliverFillRemaining(
                  child: _ErrorState(
                    message: state.errorMessage,
                    onRetry: () =>
                        ref.read(cartViewModelProvider.notifier).loadCart(),
                  ),
                )
              else if (state.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _CartItemTile(
                        item: state.cart!.items[i],
                        isOffline: isOffline,
                      ),
                      childCount: state.cart!.items.length,
                    ),
                  ),
                ),

                // ── Order summary ──────────────────────────────────────────
                SliverToBoxAdapter(child: _OrderSummary(cart: state.cart!)),

                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ],
          ),
        ),

        // ── Checkout button ────────────────────────────────────────────────
        bottomNavigationBar: state.isEmpty || isOffline
            ? null
            : _CheckoutBar(
                total: state.total,
                isLoading: state.status == CartStatus.loading,
                onCheckout: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaceOrderScreen(cart: state.cart!),
                  ),
                ),
              ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(cartViewModelProvider.notifier).clearCart();
            },
            child: Text('Clear', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _CartHeader extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onClear;
  const _CartHeader({required this.itemCount, this.onClear});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, top + 18, 20, 24),
        decoration: const BoxDecoration(
          color: _kPrimary,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Cart',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itemCount == 0
                        ? 'Your cart is empty'
                        : '$itemCount item${itemCount != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFADD8B4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Cart item tile ─────────────────────────────────────────────────────────────
class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;
  final bool isOffline;
  const _CartItemTile({required this.item, required this.isOffline});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartViewModelProvider);
    final isPending = state.isPending(item.refId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.displayImage != null
                  ? Image.network(
                      ApiEndpoints.fullImageUrl(item.displayImage!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kTextDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${item.unitPrice.toStringAsFixed(0)} each',
                  style: const TextStyle(fontSize: 11, color: _kTextLight),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Qty controls
                    if (!isOffline) ...[
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        onTap: isPending
                            ? null
                            : () {
                                if (item.quantity > 1) {
                                  ref
                                      .read(cartViewModelProvider.notifier)
                                      .updateQuantity(
                                        refId: item.refId,
                                        quantity: item.quantity - 1,
                                      );
                                } else {
                                  ref
                                      .read(cartViewModelProvider.notifier)
                                      .removeItem(item.refId);
                                }
                              },
                      ),
                      const SizedBox(width: 8),
                      isPending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: _kPrimary,
                              ),
                            )
                          : Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kTextDark,
                              ),
                            ),
                      const SizedBox(width: 8),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        onTap: isPending
                            ? null
                            : () => ref
                                  .read(cartViewModelProvider.notifier)
                                  .updateQuantity(
                                    refId: item.refId,
                                    quantity: item.quantity + 1,
                                  ),
                      ),
                    ] else
                      Text(
                        'Qty: ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kTextMid,
                        ),
                      ),

                    const Spacer(),
                    Text(
                      'Rs. ${item.subtotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove button
          if (!isOffline)
            GestureDetector(
              onTap: isPending
                  ? null
                  : () => ref
                        .read(cartViewModelProvider.notifier)
                        .removeItem(item.refId),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isPending ? _kTextLight : Colors.red.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFE8F4EE),
    child: const Center(
      child: Icon(
        Icons.local_florist_outlined,
        size: 30,
        color: Color(0xFF52B788),
      ),
    ),
  );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4EE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? _kTextLight : _kPrimary,
        ),
      ),
    );
  }
}

// ── Order summary ─────────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartEntity cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Subtotal (${cart.itemCount} items)',
            value: 'Rs. ${cart.total.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Delivery', value: 'Calculated at checkout'),
          const Divider(height: 24, color: Color(0xFFEEE8DE)),
          _SummaryRow(
            label: 'Total',
            value: 'Rs. ${cart.total.toStringAsFixed(0)}',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? _kTextDark : _kTextMid,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: bold ? _kPrimary : _kTextMid,
          ),
        ),
      ],
    );
  }
}

// ── Checkout bar ──────────────────────────────────────────────────────────────
class _CheckoutBar extends StatelessWidget {
  final double total;
  final bool isLoading;
  final VoidCallback onCheckout;
  const _CheckoutBar({
    required this.total,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 12, color: _kTextLight),
              ),
              Text(
                'Rs. ${total.toStringAsFixed(0)}',
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
              onTap: isLoading ? null : onCheckout,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
    );
  }
}

// ── Empty / error / offline states ────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: Color(0xFF52B788),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add flowers from the shop to get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _kTextLight),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _OfflineBanner({required this.onRetry});

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
          const Icon(
            Icons.wifi_off_rounded,
            size: 16,
            color: Color(0xFFB08800),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'You\'re offline — showing saved cart',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7A5E00),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
                color: _kPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorState({this.message, required this.onRetry});

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
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: Color(0xFF52B788),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Couldn't load cart",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message ?? 'Check your connection and try again',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _kTextLight),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
