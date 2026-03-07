import 'package:dartz/dartz.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';

abstract interface class INotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> clearNotification(String id);
  Future<Either<Failure, void>> clearAll();
  List<NotificationEntity> getCached();
}
