import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_client.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/orders/data/models/orders_api_model.dart';

abstract interface class IOrderRemoteDatasource {
  Future<OrderApiModel> placeOrder({
    required String paymentMethod,
    required Map<String, dynamic> deliveryDetails,
    String? notes,
  });
  Future<List<OrderApiModel>> getMyOrders({int page, int limit});
  Future<OrderApiModel> getOrderById(String id);
  Future<OrderApiModel> cancelOrder({required String id, String? reason});
}

final orderRemoteDatasourceProvider = Provider<IOrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class OrderRemoteDatasource implements IOrderRemoteDatasource {
  final ApiClient _apiClient;
  OrderRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<OrderApiModel> placeOrder({
    required String paymentMethod,
    required Map<String, dynamic> deliveryDetails,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.orders,
        data: {
          'paymentMethod': paymentMethod,
          'deliveryDetails': deliveryDetails,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.data['success'] == true) {
        // Backend returns { order, delivery } — we only need order
        final orderJson =
            response.data['data']['order'] as Map<String, dynamic>;
        return OrderApiModel.fromJson(orderJson);
      }
      throw Exception(response.data['message'] ?? 'Failed to place order');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<List<OrderApiModel>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.data['success'] == true) {
        final rawList = response.data['data'] as List<dynamic>? ?? [];
        return rawList
            .map((e) => OrderApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch orders');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<OrderApiModel> getOrderById(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.orderById(id));
      if (response.data['success'] == true) {
        final data = response.data['data'];
        // Backend wraps in { order, delivery }
        final orderJson = data is Map && data.containsKey('order')
            ? data['order'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        return OrderApiModel.fromJson(orderJson);
      }
      throw Exception(response.data['message'] ?? 'Order not found');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<OrderApiModel> cancelOrder({
    required String id,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.cancelOrder(id),
        data: {'reason': reason ?? 'Cancelled by customer'},
      );
      if (response.data['success'] == true) {
        return OrderApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Failed to cancel order');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }
}
