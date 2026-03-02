import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/items/data/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';
import 'package:sprint1_project/features/items/domain/repositories/item_repository.dart';

class GetItemByIdParams extends Equatable {
  final String itemId;
  const GetItemByIdParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

final getItemByIdUsecaseProvider = Provider<GetItemByIdUsecase>((ref) {
  return GetItemByIdUsecase(repository: ref.read(itemRepositoryProvider));
});

class GetItemByIdUsecase
    implements UseCaseWithParams<DataResult<ItemEntity>, GetItemByIdParams> {
  final IItemRepository _repository;

  GetItemByIdUsecase({required IItemRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, DataResult<ItemEntity>>> call(
    GetItemByIdParams params,
  ) {
    return _repository.getItemById(params.itemId);
  }
}
