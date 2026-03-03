import 'package:flutter/material.dart';
import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';

const _kPrimary = Color(0xFF1B4332);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextLight = Color(0xFF9E9E9E);

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onClear(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.red.shade600,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: isUnread ? onTap : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFF0F7F3) : _kSurface,
            borderRadius: BorderRadius.circular(16),
            border: isUnread
                ? Border.all(color: _kPrimary.withOpacity(0.15))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationTypeIcon(type: notification.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: _kTextDark,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _kPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5C5C5C),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: const TextStyle(fontSize: 11, color: _kTextLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class NotificationTypeIcon extends StatelessWidget {
  final String type;
  const NotificationTypeIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      'success' => (
        Icons.check_circle_outline_rounded,
        const Color(0xFF2D6A4F),
      ),
      'warning' => (Icons.warning_amber_rounded, const Color(0xFFB08800)),
      'promo' => (Icons.local_offer_outlined, const Color(0xFF7209B7)),
      _ => (Icons.info_outline_rounded, _kPrimary),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
