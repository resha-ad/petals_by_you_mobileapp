import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_client.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/items/data/datasources/item_datasource.dart';
import 'package:sprint1_project/features/items/data/models/item_api_model.dart';

final itemRemoteDatasourceProvider = Provider<IItemRemoteDataSource>((ref) {
  return ItemRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ItemRemoteDatasource implements IItemRemoteDataSource {
  final ApiClient _apiClient;

  ItemRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  // GET /api/items
  // Backend returns: { success, data: { items: [...], pagination: {...} } }
  @override
  Future<List<ItemApiModel>> getItems({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? featured,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (featured != null) 'featured': featured,
        if (sort != null) 'sort': sort,
      };

      final response = await _apiClient.dio.get(
        ApiEndpoints.items,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final itemsJson =
            response.data['data']['items'] as List<dynamic>? ?? [];
        return itemsJson
            .map((j) => ItemApiModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch items');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  // GET /api/items/:id
  @override
  Future<ItemApiModel> getItemById(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.itemById(id));
      if (response.data['success'] == true) {
        return ItemApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Item not found');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }
}
