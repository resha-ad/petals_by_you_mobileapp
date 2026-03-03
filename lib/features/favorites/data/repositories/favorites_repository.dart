import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/core/services/hive/hive_service.dart';
import 'package:sprint1_project/features/favorites/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:sprint1_project/features/favorites/data/models/favorites_hive_model.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<IFavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(
    remote: ref.read(favoritesRemoteDatasourceProvider),
    hive: ref.read(hiveServiceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class FavoritesRepositoryImpl implements IFavoritesRepository {
  final IFavoritesRemoteDatasource _remote;
  final HiveService _hive;
  final INetworkInfo _networkInfo;

  FavoritesRepositoryImpl({
    required IFavoritesRemoteDatasource remote,
    required HiveService hive,
    required INetworkInfo networkInfo,
  }) : _remote = remote,
       _hive = hive,
       _networkInfo = networkInfo;

  // ── getFavorites ───────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, FavoritesEntity>> getFavorites() async {
    final hasInternet = await _networkInfo.isConnected;

    // Offline → serve from Hive cache
    if (!hasInternet) {
      final cached = _hive.getCachedFavorites();
      return Right(
        FavoritesEntity(
          userId: '',
          items: cached.map((m) => m.toEntity()).toList(),
        ),
      );
    }

    // Online → fetch, cache, return
    try {
      final model = await _remote.getFavorites();
      final entity = model.toEntity();
      await _cacheFavorites(entity.items);
      return Right(entity);
    } catch (e) {
      // Network failed — fall back to cache rather than showing an error
      final cached = _hive.getCachedFavorites();
      if (cached.isNotEmpty) {
        return Right(
          FavoritesEntity(
            userId: '',
            items: cached.map((m) => m.toEntity()).toList(),
          ),
        );
      }
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ── addFavorite ────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, FavoritesEntity>> addFavorite({
    required String type,
    required String refId,
  }) async {
    // Guard: refuse when offline
    final hasInternet = await _networkInfo.isConnected;
    if (!hasInternet) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to add favourites.'),
      );
    }

    try {
      final model = await _remote.addFavorite(type: type, refId: refId);
      final entity = model.toEntity();
      await _cacheFavorites(entity.items);
      return Right(entity);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ── removeFavorite ─────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, FavoritesEntity>> removeFavorite(String refId) async {
    // Guard: refuse when offline
    final hasInternet = await _networkInfo.isConnected;
    if (!hasInternet) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to remove favourites.'),
      );
    }

    try {
      final model = await _remote.removeFavorite(refId);
      final entity = model.toEntity();
      await _cacheFavorites(entity.items);
      return Right(entity);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ── _cacheFavorites ────────────────────────────────────────────────────────
  Future<void> _cacheFavorites(List<FavoriteEntity> items) async {
    final hiveModels = items.map(FavoriteItemHiveModel.fromEntity).toList();
    await _hive.saveFavorites(hiveModels);
  }
}
