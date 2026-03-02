import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/items/data/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';
import 'package:sprint1_project/features/items/domain/repositories/item_repository.dart';

class GetItemsParams extends Equatable {
  final int page;
  final int limit;
  final String? search;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? featured;
  final String? sort;

  const GetItemsParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.featured,
    this.sort,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    search,
    category,
    minPrice,
    maxPrice,
    featured,
    sort,
  ];
}

final getItemsUsecaseProvider = Provider<GetItemsUsecase>((ref) {
  return GetItemsUsecase(repository: ref.read(itemRepositoryProvider));
});

class GetItemsUsecase
    implements UseCaseWithParams<DataResult<List<ItemEntity>>, GetItemsParams> {
  final IItemRepository _repository;

  GetItemsUsecase({required IItemRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, DataResult<List<ItemEntity>>>> call(
    GetItemsParams params,
  ) {
    return _repository.getItems(
      page: params.page,
      limit: params.limit,
      search: params.search,
      category: params.category,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      featured: params.featured,
      sort: params.sort,
    );
  }
}
