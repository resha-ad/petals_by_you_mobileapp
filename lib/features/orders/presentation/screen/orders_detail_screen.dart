import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/delivery/presentation/widgets/delivery_tracking_section_widget.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/presentation/view_model/orders_view_model.dart';

const _kPrimary = Color(0xFF1B4332);
const _kBackground = Color(0xFFF9F6F0);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersViewModelProvider.notifier).loadOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);
    final order = state.selectedOrder;
    final isPending = state.isPending(widget.orderId);

    if (state.status == OrdersStatus.loading && order == null) {
      return Scaffold(
        backgroundColor: _kBackground,
        body: const Center(
          child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2),
        ),
      );
    }

    if (order == null || state.status == OrdersStatus.error) {
      return Scaffold(
        backgroundColor: _kBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: _kTextDark),
        ),
        body: Center(
          child: Text(
            state.errorMessage ?? 'Order not found',
            style: const TextStyle(color: _kTextMid),
          ),
        ),
      );
    }

    final statusColor = _statusColor(order.status);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kBackground,
        body: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _DetailHeader(
                orderId: order.id,
                onBack: () => Navigator.pop(context),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Status card ─────────────────────────────────────────
                  _StatusCard(order: order, statusColor: statusColor),
                  const SizedBox(height: 16),

                  // ── Delivery tracking section ───────────────────────────
                  DeliveryTrackingSection(orderId: order.id),
                  const SizedBox(height: 16),

                  // ── Items ───────────────────────────────────────────────
                  _SectionCard(
                    title: 'Items',
                    child: Column(
                      children: order.items
                          .map((item) => _OrderItemRow(item: item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Payment summary ─────────────────────────────────────
                  _SectionCard(
                    title: 'Payment',
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Method',
                          value: order.paymentMethod == 'cash_on_delivery'
                              ? 'Cash on Delivery'
                              : 'Online',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Status',
                          value: order.paymentStatus.toUpperCase(),
                          valueColor: order.paymentStatus == 'paid'
                              ? const Color(0xFF2D6A4F)
                              : const Color(0xFFB08800),
                        ),
                        const Divider(height: 20, color: Color(0xFFEEE8DE)),
                        _InfoRow(
                          label: 'Total',
                          value: 'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Notes ───────────────────────────────────────────────
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Notes',
                      child: Text(
                        order.notes!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _kTextMid,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Cancellation details ────────────────────────────────
                  if (order.status == OrderStatus.cancelled &&
                      order.cancelReason != null) ...[
                    _SectionCard(
                      title: 'Cancellation',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.cancelReason!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _kTextMid,
                              height: 1.5,
                            ),
                          ),
                          if (order.cancelledAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Cancelled on ${_formatDate(order.cancelledAt!)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _kTextLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Cancel button ───────────────────────────────────────
                  if (order.isCancellable)
                    GestureDetector(
                      onTap: isPending
                          ? null
                          : () => _confirmCancel(context, order),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: isPending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                )
                              : Text(
                                  'Cancel Order',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(ordersViewModelProvider.notifier)
                  .cancelOrder(order.id, reason: 'Cancelled by customer');
            },
            child: Text(
              'Cancel Order',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────
class _DetailHeader extends StatelessWidget {
  final String orderId;
  final VoidCallback onBack;
  const _DetailHeader({required this.orderId, required this.onBack});

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
                color: Colors.white.withValues(alpha: 0.12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '#${orderId.substring(orderId.length > 8 ? orderId.length - 8 : 0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFADD8B4),
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

class _StatusCard extends StatelessWidget {
  final OrderEntity order;
  final Color statusColor;
  const _StatusCard({required this.order, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(order.status),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.displayLabel,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusDescription(order.status),
                  style: const TextStyle(fontSize: 12, color: _kTextMid),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.local_florist_rounded;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _statusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Awaiting confirmation from our team';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed';
      case OrderStatus.preparing:
        return 'Our florists are preparing your order';
      case OrderStatus.outForDelivery:
        return 'Your order is on its way';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'This order has been cancelled';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItemEntity item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 52,
              height: 52,
              child: item.imageUrl != null
                  ? Image.network(
                      ApiEndpoints.fullImageUrl(item.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextDark,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity} × Rs. ${item.unitPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: _kTextLight),
                ),
              ],
            ),
          ),
          Text(
            'Rs. ${item.subtotal.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kPrimary,
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
        size: 24,
        color: Color(0xFF52B788),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
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
            fontSize: bold ? 14 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? _kTextDark : _kTextMid,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (bold ? _kPrimary : _kTextDark),
          ),
        ),
      ],
    );
  }
}
