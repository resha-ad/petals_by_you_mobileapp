import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF1B4332);

class CartHeader extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onClear;
  const CartHeader({super.key, required this.itemCount, this.onClear});

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
