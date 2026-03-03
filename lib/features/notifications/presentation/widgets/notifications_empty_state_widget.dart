import 'package:flutter/material.dart';

const _kTextDark = Color(0xFF1A1A1A);
const _kTextLight = Color(0xFF9E9E9E);

class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: Color(0xFF52B788)),
          SizedBox(height: 16),
          Text('No notifications',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark)),
          SizedBox(height: 6),
          Text("You're all caught up!",
              style: TextStyle(fontSize: 13, color: _kTextLight)),
        ],
      ),
    );
  }
}
