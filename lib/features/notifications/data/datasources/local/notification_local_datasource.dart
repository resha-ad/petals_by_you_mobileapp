import 'package:hive/hive.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/notifications/data/models/notification_hive_model.dart';
import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';

abstract interface class INotificationLocalDatasource {
  Future<void> saveNotifications(List<NotificationEntity> notifications);
  List<NotificationEntity> getCachedNotifications();
  Future<void> updateNotification(NotificationEntity notification);
  Future<void> clearAll();
}

class NotificationLocalDatasource implements INotificationLocalDatasource {
  Box<NotificationHiveModel> get _box =>
      Hive.box<NotificationHiveModel>(HiveTableConstant.notificationTable);

  @override
  Future<void> saveNotifications(List<NotificationEntity> notifications) async {
    await _box.clear();
    await _box.putAll({
      for (final n in notifications) n.id: NotificationHiveModel.fromEntity(n),
    });
  }

  @override
  List<NotificationEntity> getCachedNotifications() =>
      _box.values.map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<void> updateNotification(NotificationEntity notification) async {
    await _box.put(
      notification.id,
      NotificationHiveModel.fromEntity(notification),
    );
  }

  @override
  Future<void> clearAll() async => _box.clear();
}
