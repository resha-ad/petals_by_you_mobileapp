import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_client.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/custom_bouquet/data/models/custom_bouquet_api_model.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';

abstract interface class ICustomBouquetRemoteDatasource {
  /// Sends the bouquet to the backend, which creates it and adds it to cart.
  Future<CustomBouquetApiModel> createAndAddToCart(CustomBouquetEntity bouquet);
}

final customBouquetRemoteDatasourceProvider =
    Provider<ICustomBouquetRemoteDatasource>((ref) {
      return CustomBouquetRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class CustomBouquetRemoteDatasource implements ICustomBouquetRemoteDatasource {
  final ApiClient _apiClient;
  CustomBouquetRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<CustomBouquetApiModel> createAndAddToCart(
    CustomBouquetEntity bouquet,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.customBouquets,
        data: bouquet.toPayload(),
      );
      if (response.data['success'] == true) {
        final bouquetJson =
            response.data['data']['bouquet'] as Map<String, dynamic>;
        return CustomBouquetApiModel.fromJson(bouquetJson);
      }
      throw Exception(response.data['message'] ?? 'Failed to create bouquet');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }
}
