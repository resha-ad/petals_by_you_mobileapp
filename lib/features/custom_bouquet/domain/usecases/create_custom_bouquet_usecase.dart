import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/custom_bouquet/data/repositories/custom_bouquet_repository.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/repositories/custom_bouquet_repository.dart';

final createCustomBouquetUsecaseProvider = Provider<CreateCustomBouquetUsecase>(
  (ref) {
    return CreateCustomBouquetUsecase(
      ref.read(customBouquetRepositoryProvider),
    );
  },
);

class CreateCustomBouquetUsecase
    implements UseCaseWithParams<String, CustomBouquetEntity> {
  final ICustomBouquetRepository _repo;
  CreateCustomBouquetUsecase(this._repo);

  @override
  Future<Either<Failure, String>> call(CustomBouquetEntity params) =>
      _repo.createAndAddToCart(params);
}
