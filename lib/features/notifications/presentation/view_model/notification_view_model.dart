import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/core/services/notifications/push_notification_service.dart';
import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';
import 'package:sprint1_project/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:sprint1_project/features/notifications/presentation/state/notification_state.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
      NotificationViewModel.new,
    );

class NotificationViewModel extends Notifier<NotificationState> {
  late final GetNotificationsUsecase _getNotifications;
  late final MarkNotificationReadUsecase _markRead;
  late final MarkAllReadUsecase _markAllRead;
  late final ClearNotificationUsecase _clearOne;
  late final ClearAllNotificationsUsecase _clearAll;
  late final INetworkInfo _networkInfo;

  @override
  NotificationState build() {
    _getNotifications = ref.read(getNotificationsUsecaseProvider);
    _markRead = ref.read(markNotificationReadUsecaseProvider);
    _markAllRead = ref.read(markAllReadUsecaseProvider);
    _clearOne = ref.read(clearNotificationUsecaseProvider);
    _clearAll = ref.read(clearAllNotificationsUsecaseProvider);
    _networkInfo = ref.read(networkInfoProvider);
    return const NotificationState();
  }

  Future<void> load() async {
    state = state.copyWith(
      status: NotificationStatus.loading,
      clearError: true,
    );
    final isOnline = await _networkInfo.isConnected;
    final result = await _getNotifications();
    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (notifications) {
        // Show push notifications for any new unread ones
        _pushNewNotifications(notifications);
        state = state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
          isFromCache: !isOnline,
        );
      },
    );
  }

  Future<void> markRead(String id) async {
    // Optimistic update
    final updated = state.notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    state = state.copyWith(notifications: updated);
    await _markRead(id);
  }

  Future<void> markAllRead() async {
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated);
    await _markAllRead();
  }

  Future<void> clearOne(String id) async {
    final updated = state.notifications
        .map((n) => n.id == id ? n.copyWith(isCleared: true) : n)
        .toList();
    state = state.copyWith(notifications: updated);
    await _clearOne(id);
  }

  Future<void> clearAll() async {
    state = state.copyWith(notifications: const []);
    await _clearAll();
  }

  void _pushNewNotifications(List<NotificationEntity> fresh) {
    final previousIds = state.notifications.map((n) => n.id).toSet();
    final brandNew = fresh.where(
      (n) => !previousIds.contains(n.id) && !n.isRead,
    );
    for (final n in brandNew) {
      PushNotificationService.instance.showNotification(
        id: n.id.hashCode,
        title: n.title,
        body: n.message,
      );
    }
  }
}
