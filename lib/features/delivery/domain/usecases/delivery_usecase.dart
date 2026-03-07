import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/delivery/data/repositories/delivery_repository.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';
import 'package:sprint1_project/features/delivery/domain/repositories/delivery_repository.dart';

// ── GetDeliveryByOrderId ──────────────────────────────────────────────────────
final getDeliveryByOrderIdUsecaseProvider =
    Provider<GetDeliveryByOrderIdUsecase>((ref) {
      return GetDeliveryByOrderIdUsecase(ref.read(deliveryRepositoryProvider));
    });

class GetDeliveryByOrderIdUsecase
    implements UseCaseWithParams<DeliveryEntity, String> {
  final IDeliveryRepository _repo;
  GetDeliveryByOrderIdUsecase(this._repo);

  @override
  Future<Either<Failure, DeliveryEntity>> call(String orderId) =>
      _repo.getDeliveryByOrderId(orderId);
}
