import 'package:dartz/dartz.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';

abstract interface class ICustomBouquetRepository {
  Future<Either<Failure, String>> createAndAddToCart(
    CustomBouquetEntity bouquet,
  );
}
