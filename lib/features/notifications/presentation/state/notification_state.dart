import 'package:equatable/equatable.dart';
import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;
  final bool isFromCache;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.isFromCache = false,
  });

  int get unreadCount =>
      notifications.where((n) => !n.isRead && !n.isCleared).length;

  List<NotificationEntity> get visible =>
      notifications.where((n) => !n.isCleared).toList();

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
    bool clearError = false,
    bool? isFromCache,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage, isFromCache];
}
