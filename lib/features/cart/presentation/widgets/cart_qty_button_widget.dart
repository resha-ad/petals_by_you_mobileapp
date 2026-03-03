import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF1B4332);
const _kTextLight = Color(0xFF9E9E9E);

class CartQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const CartQtyButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFF0EDE8)
              : const Color(0xFFE8F4EE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16, color: onTap == null ? _kTextLight : _kPrimary),
      ),
    );
  }
}
