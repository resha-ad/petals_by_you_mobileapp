import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/notifications/data/repositories/notification_repository.dart';
import 'package:sprint1_project/features/notifications/domain/repositories/notification_repository.dart';

final clearNotificationUsecaseProvider = Provider<ClearNotificationUsecase>(
  (ref) =>
      ClearNotificationUsecase(ref.read(notificationRepositoryProvider)),
);

class ClearNotificationUsecase implements UseCaseWithParams<void, String> {
  final INotificationRepository _repo;
  ClearNotificationUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(String id) =>
      _repo.clearNotification(id);
}
