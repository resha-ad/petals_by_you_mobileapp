import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';

class NotificationApiModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String targetRole;
  final bool isRead;
  final bool isCleared;
  final DateTime createdAt;

  const NotificationApiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.targetRole,
    required this.isRead,
    required this.isCleared,
    required this.createdAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      targetRole: json['targetRole']?.toString() ?? 'all',
      isRead: json['isRead'] as bool? ?? false,
      isCleared: json['isCleared'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  NotificationEntity toEntity() => NotificationEntity(
    id: id,
    title: title,
    message: message,
    type: type,
    targetRole: targetRole,
    isRead: isRead,
    isCleared: isCleared,
    createdAt: createdAt,
  );
}
