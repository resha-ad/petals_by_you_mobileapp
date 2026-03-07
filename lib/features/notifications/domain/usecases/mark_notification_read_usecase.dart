import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/notifications/data/repositories/notification_repository.dart';
import 'package:sprint1_project/features/notifications/domain/repositories/notification_repository.dart';

final markNotificationReadUsecaseProvider =
    Provider<MarkNotificationReadUsecase>(
  (ref) =>
      MarkNotificationReadUsecase(ref.read(notificationRepositoryProvider)),
);

class MarkNotificationReadUsecase implements UseCaseWithParams<void, String> {
  final INotificationRepository _repo;
  MarkNotificationReadUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(String id) => _repo.markAsRead(id);
}
