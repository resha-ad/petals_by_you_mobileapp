import 'package:hive/hive.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';

part 'notification_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.notificationTypeId)
class NotificationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String targetRole;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final bool isCleared;

  @HiveField(7)
  final DateTime createdAt;

  NotificationHiveModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.targetRole,
    required this.isRead,
    required this.isCleared,
    required this.createdAt,
  });

  factory NotificationHiveModel.fromEntity(NotificationEntity e) =>
      NotificationHiveModel(
        id: e.id,
        title: e.title,
        message: e.message,
        type: e.type,
        targetRole: e.targetRole,
        isRead: e.isRead,
        isCleared: e.isCleared,
        createdAt: e.createdAt,
      );

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
