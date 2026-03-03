import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/custom_bouquet/data/datasources/remote/custom_bouquet_remote_datasource.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/repositories/custom_bouquet_repository.dart';

final customBouquetRepositoryProvider = Provider<ICustomBouquetRepository>((
  ref,
) {
  return CustomBouquetRepositoryImpl(
    remote: ref.read(customBouquetRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class CustomBouquetRepositoryImpl implements ICustomBouquetRepository {
  final ICustomBouquetRemoteDatasource _remote;
  final INetworkInfo _networkInfo;

  CustomBouquetRepositoryImpl({
    required ICustomBouquetRemoteDatasource remote,
    required INetworkInfo networkInfo,
  }) : _remote = remote,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, String>> createAndAddToCart(
    CustomBouquetEntity bouquet,
  ) async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to build a bouquet.'),
      );
    }
    try {
      final result = await _remote.createAndAddToCart(bouquet);
      return Right(result.id);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
