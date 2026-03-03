import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/presentation/screen/orders_detail_screen.dart';
import 'package:sprint1_project/features/orders/presentation/view_model/orders_view_model.dart';

const _kPrimary = Color(0xFF1B4332);
const _kBackground = Color(0xFFF9F6F0);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersViewModelProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);
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
          onRefresh: () =>
              ref.read(ordersViewModelProvider.notifier).loadOrders(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _OrdersHeader(onBack: () => Navigator.pop(context)),
              ),

              // ── Offline banner ───────────────────────────────────────────
              if (isOffline)
                SliverToBoxAdapter(
                  child: _OfflineBanner(
                    onRetry: () =>
                        ref.read(ordersViewModelProvider.notifier).loadOrders(),
                  ),
                ),

              // ── Body ────────────────────────────────────────────────────
              if (state.status == OrdersStatus.loading && state.orders.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _kPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (state.status == OrdersStatus.error &&
                  state.orders.isEmpty)
                SliverFillRemaining(
                  child: _ErrorState(
                    message: state.errorMessage,
                    onRetry: () =>
                        ref.read(ordersViewModelProvider.notifier).loadOrders(),
                  ),
                )
              else if (state.orders.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _OrderCard(
                        order: state.orders[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailScreen(orderId: state.orders[i].id),
                          ),
                        ),
                      ),
                      childCount: state.orders.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _OrdersHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _OrdersHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 18, 20, 24),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Orders',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track and manage your orders',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFADD8B4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
            // Top row: order ID + status badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kTextDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: _kTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.displayLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEE8DE)),
            const SizedBox(height: 12),

            // Items summary
            Text(
              order.items.map((i) => i.name).take(2).join(', ') +
                  (order.items.length > 2
                      ? ' +${order.items.length - 2} more'
                      : ''),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: _kTextMid,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 10),

            // Bottom row: total + payment method
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      order.paymentMethod == 'cash_on_delivery'
                          ? Icons.payments_outlined
                          : Icons.credit_card_outlined,
                      size: 14,
                      color: _kTextLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.paymentMethod == 'cash_on_delivery'
                          ? 'Cash on Delivery'
                          : 'Online',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kTextLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFB08800);
      case OrderStatus.confirmed:
        return const Color(0xFF1B4332);
      case OrderStatus.preparing:
        return const Color(0xFF0077B6);
      case OrderStatus.outForDelivery:
        return const Color(0xFF7209B7);
      case OrderStatus.delivered:
        return const Color(0xFF2D6A4F);
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ── Offline banner ────────────────────────────────────────────────────────────
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
              'You\'re offline — showing saved orders',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 60, color: Color(0xFF52B788)),
          SizedBox(height: 18),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your order history will appear here',
            style: TextStyle(fontSize: 13, color: _kTextLight),
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
            'Couldn\'t load orders',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message ?? 'Check your connection',
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
