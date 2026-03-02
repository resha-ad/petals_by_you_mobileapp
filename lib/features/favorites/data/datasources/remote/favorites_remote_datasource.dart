import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_client.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/favorites/data/models/favorite_api_model.dart';
import 'package:sprint1_project/features/items/data/models/item_api_model.dart';

abstract interface class IFavoritesRemoteDatasource {
  Future<FavoritesApiModel> getFavorites();
  Future<FavoritesApiModel> addFavorite({
    required String type,
    required String refId,
  });
  Future<FavoritesApiModel> removeFavorite(String refId);
}

final favoritesRemoteDatasourceProvider = Provider<IFavoritesRemoteDatasource>((
  ref,
) {
  return FavoritesRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class FavoritesRemoteDatasource implements IFavoritesRemoteDatasource {
  final ApiClient _apiClient;

  FavoritesRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  // ── getFavorites ───────────────────────────────────────────────────────────
  @override
  Future<FavoritesApiModel> getFavorites() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.favorites);
      debugPrint('[Favorites] GET /favorites raw: \${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];

        if (data == null) {
          debugPrint('[Favorites] data is null, returning empty');
          return const FavoritesApiModel(userId: '', items: []);
        }

        final parsed = FavoritesApiModel.fromJson(data as Map<String, dynamic>);
        debugPrint(
          '[Favorites] parsed \${parsed.items.length} items, '
          'refItem populated: \${parsed.items.map((i) => i.refItem != null).toList()}',
        );

        // Self-heal: if items exist but none are populated, fetch them
        final needsFetch =
            parsed.items.isNotEmpty &&
            parsed.items.every((i) => i.refItem == null && i.type == 'product');

        if (needsFetch) {
          debugPrint(
            '[Favorites] refItems not populated — fetching individually',
          );
          return await _enrichWithItemDetails(parsed);
        }

        return parsed;
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch favorites');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  // ── addFavorite ────────────────────────────────────────────────────────────
  @override
  Future<FavoritesApiModel> addFavorite({
    required String type,
    required String refId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.favoritesAdd,
        data: {'type': type, 'refId': refId},
      );
      if (response.data['success'] == true) {
        final parsed = FavoritesApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        final needsFetch =
            parsed.items.isNotEmpty &&
            parsed.items.every((i) => i.refItem == null && i.type == 'product');
        if (needsFetch) return await _enrichWithItemDetails(parsed);
        return parsed;
      }
      throw Exception(response.data['message'] ?? 'Failed to add favorite');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  // ── removeFavorite ─────────────────────────────────────────────────────────
  @override
  Future<FavoritesApiModel> removeFavorite(String refId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.favoritesRemove(refId),
      );
      if (response.data['success'] == true) {
        final parsed = FavoritesApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        final needsFetch =
            parsed.items.isNotEmpty &&
            parsed.items.every((i) => i.refItem == null && i.type == 'product');
        if (needsFetch) return await _enrichWithItemDetails(parsed);
        return parsed;
      }
      throw Exception(response.data['message'] ?? 'Failed to remove favorite');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  // ── _enrichWithItemDetails ─────────────────────────────────────────────────
  /// Fallback: if the backend didn't populate refId, fetch each product
  /// individually using GET /api/items/:id and merge the data in.
  /// This is safe — it only fires when populate returned plain IDs.
  Future<FavoritesApiModel> _enrichWithItemDetails(
    FavoritesApiModel parsed,
  ) async {
    final enriched = await Future.wait(
      parsed.items.map((favItem) async {
        if (favItem.type != 'product' || favItem.refId.isEmpty) {
          return favItem;
        }
        try {
          final res = await _apiClient.dio.get(
            ApiEndpoints.itemById(favItem.refId),
          );
          debugPrint(
            '[Favorites] fetched item \${favItem.refId}: success=\${res.data}',
          );
          if (res.data['success'] == true) {
            final itemModel = ItemApiModel.fromJson(
              res.data['data'] as Map<String, dynamic>,
            );
            return FavoriteItemApiModel(
              type: favItem.type,
              refId: favItem.refId,
              refItem: itemModel,
            );
          }
        } catch (e) {
          debugPrint('[Favorites] failed to fetch item \${favItem.refId}: \$e');
        }
        return favItem;
      }),
    );

    return FavoritesApiModel(userId: parsed.userId, items: enriched);
  }
}
