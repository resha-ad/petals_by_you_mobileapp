import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/notifications/data/datasources/local/notification_local_datasource.dart';
import 'package:sprint1_project/features/notifications/data/datasources/remote/notification_remote_datasource.dart';
import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';
import 'package:sprint1_project/features/notifications/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remote: ref.read(notificationRemoteDatasourceProvider),
    local: NotificationLocalDatasource(),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class NotificationRepositoryImpl implements INotificationRepository {
  final INotificationRemoteDatasource _remote;
  final INotificationLocalDatasource _local;
  final INetworkInfo _networkInfo;

  NotificationRepositoryImpl({
    required INotificationRemoteDatasource remote,
    required INotificationLocalDatasource local,
    required INetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return Right(_local.getCachedNotifications());
    }
    try {
      final models = await _remote.getMyNotifications();
      final entities = models.map((m) => m.toEntity()).toList();
      await _local.saveNotifications(entities);
      return Right(entities);
    } catch (e) {
      final cached = _local.getCachedNotifications();
      if (cached.isNotEmpty) return Right(cached);
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      await _remote.markAsRead(id);
      final cached = _local.getCachedNotifications();
      final updated = cached.firstWhere(
        (n) => n.id == id,
        orElse: () => throw Exception(),
      );
      await _local.updateNotification(updated.copyWith(isRead: true));
      return const Right(null);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _remote.markAllAsRead();
      final cached = _local.getCachedNotifications();
      for (final n in cached) {
        await _local.updateNotification(n.copyWith(isRead: true));
      }
      return const Right(null);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearNotification(String id) async {
    try {
      await _remote.clearNotification(id);
      final cached = _local.getCachedNotifications();
      final updated = cached.firstWhere(
        (n) => n.id == id,
        orElse: () => throw Exception(),
      );
      await _local.updateNotification(
        updated.copyWith(isCleared: true, isRead: true),
      );
      return const Right(null);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      await _remote.clearAll();
      await _local.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  List<NotificationEntity> getCached() => _local.getCachedNotifications();
}
