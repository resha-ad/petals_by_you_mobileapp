import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/notifications/data/repositories/notification_repository.dart';
import 'package:sprint1_project/features/notifications/domain/repositories/notification_repository.dart';

final markAllReadUsecaseProvider = Provider<MarkAllReadUsecase>(
  (ref) => MarkAllReadUsecase(ref.read(notificationRepositoryProvider)),
);

class MarkAllReadUsecase implements UseCaseWithoutParams<void> {
  final INotificationRepository _repo;
  MarkAllReadUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call() => _repo.markAllAsRead();
}
