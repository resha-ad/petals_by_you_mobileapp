import 'package:flutter/material.dart';

const _kTextLight = Color(0xFF9E9E9E);

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFE8F4EE),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Icon(Icons.shopping_bag_outlined,
                  size: 40, color: Color(0xFF52B788)),
            ),
          ),
          SizedBox(height: 18),
          Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          SizedBox(height: 6),
          Text('Add flowers from the shop to get started',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _kTextLight)),
        ],
      ),
    );
  }
}
