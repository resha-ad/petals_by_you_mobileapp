import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/notifications/data/repositories/notification_repository.dart';
import 'package:sprint1_project/features/notifications/domain/entities/notification_entity.dart';
import 'package:sprint1_project/features/notifications/domain/repositories/notification_repository.dart';

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>(
  (ref) => GetNotificationsUsecase(ref.read(notificationRepositoryProvider)),
);

class GetNotificationsUsecase
    implements UseCaseWithoutParams<List<NotificationEntity>> {
  final INotificationRepository _repo;
  GetNotificationsUsecase(this._repo);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call() =>
      _repo.getNotifications();
}
