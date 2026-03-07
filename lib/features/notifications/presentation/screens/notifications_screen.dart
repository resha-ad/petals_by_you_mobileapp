import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/app/themes/app_colors.dart';
import 'package:sprint1_project/features/notifications/presentation/state/notification_state.dart';
import 'package:sprint1_project/features/notifications/presentation/view_model/notification_view_model.dart';
import 'package:sprint1_project/features/notifications/presentation/widgets/notification_widgets.dart';

const _kPrimary = Color(0xFF1B4332);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationViewModelProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationViewModelProvider);
    final visible = state.visible;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: RefreshIndicator(
          color: _kPrimary,
          backgroundColor: AppColors.surface(context),
          onRefresh: () =>
              ref.read(notificationViewModelProvider.notifier).load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _NotificationsHeader(
                  unreadCount: state.unreadCount,
                  onBack: () => Navigator.pop(context),
                  onMarkAll: state.unreadCount > 0
                      ? () => ref
                            .read(notificationViewModelProvider.notifier)
                            .markAllRead()
                      : null,
                  onClearAll: visible.isNotEmpty
                      ? () => _confirmClearAll(context)
                      : null,
                ),
              ),
              if (state.status == NotificationStatus.loading && visible.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _kPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (visible.isEmpty)
                const SliverFillRemaining(child: NotificationsEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => NotificationTile(
                        notification: visible[i],
                        onTap: () => ref
                            .read(notificationViewModelProvider.notifier)
                            .markRead(visible[i].id),
                        onClear: () => ref
                            .read(notificationViewModelProvider.notifier)
                            .clearOne(visible[i].id),
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All Notifications',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        content: Text(
          'Remove all notifications?',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notificationViewModelProvider.notifier).clearAll();
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onBack;
  final VoidCallback? onMarkAll;
  final VoidCallback? onClearAll;

  const _NotificationsHeader({
    required this.unreadCount,
    required this.onBack,
    this.onMarkAll,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 18, 20, 24),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (unreadCount > 0)
                      Text(
                        '$unreadCount unread',
                        style: const TextStyle(
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
          if (onMarkAll != null || onClearAll != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (onMarkAll != null)
                  _ActionChip(
                    label: 'Mark all read',
                    icon: Icons.done_all_rounded,
                    onTap: onMarkAll!,
                  ),
                if (onMarkAll != null && onClearAll != null)
                  const SizedBox(width: 8),
                if (onClearAll != null)
                  _ActionChip(
                    label: 'Clear all',
                    icon: Icons.clear_all_rounded,
                    onTap: onClearAll!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
