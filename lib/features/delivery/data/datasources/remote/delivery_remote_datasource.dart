import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_client.dart';
import 'package:sprint1_project/features/delivery/data/models/delivery_api_model.dart';

abstract interface class IDeliveryRemoteDatasource {
  /// GET /api/orders/:orderId  → returns { order, delivery }
  /// We parse only the delivery portion.
  Future<DeliveryApiModel?> getDeliveryByOrderId(String orderId);
}

final deliveryRemoteDatasourceProvider = Provider<IDeliveryRemoteDatasource>((
  ref,
) {
  return DeliveryRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class DeliveryRemoteDatasource implements IDeliveryRemoteDatasource {
  final ApiClient _apiClient;
  DeliveryRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<DeliveryApiModel?> getDeliveryByOrderId(String orderId) async {
    try {
      // Reuse the existing order detail endpoint — it already returns delivery
      final response = await _apiClient.dio.get('/orders/$orderId');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map && data.containsKey('delivery')) {
          final deliveryJson = data['delivery'];
          if (deliveryJson == null) return null;
          return DeliveryApiModel.fromJson(
            deliveryJson as Map<String, dynamic>,
          );
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }
}
