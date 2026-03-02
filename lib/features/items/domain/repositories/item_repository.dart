import 'package:dartz/dartz.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/items/data/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

abstract interface class IItemRepository {
  Future<Either<Failure, DataResult<List<ItemEntity>>>> getItems({
    int page,
    int limit,
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? featured,
    String? sort,
  });

  Future<Either<Failure, DataResult<ItemEntity>>> getItemById(String id);

  bool hasCachedItems();
  List<ItemEntity> getCachedItems();
  bool isCacheFresh({Duration maxAge});
}
