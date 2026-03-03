import 'package:flutter/material.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';

const _kPrimary = Color(0xFF1B4332);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;
  const OrderCard({super.key, required this.order, required this.onTap});

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
