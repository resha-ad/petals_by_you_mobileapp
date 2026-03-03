import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_client.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/cart/data/models/cart_api_model.dart';

abstract interface class ICartRemoteDatasource {
  Future<CartApiModel> getCart();
  Future<CartApiModel> addProduct({
    required String itemId,
    required int quantity,
  });
  Future<CartApiModel> removeItem(String refId);
  Future<CartApiModel> updateQuantity({
    required String refId,
    required int quantity,
  });
  Future<CartApiModel> clearCart();
}

final cartRemoteDatasourceProvider = Provider<ICartRemoteDatasource>((ref) {
  return CartRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class CartRemoteDatasource implements ICartRemoteDatasource {
  final ApiClient _apiClient;
  CartRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<CartApiModel> getCart() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.cart);
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) {
          return const CartApiModel(userId: '', items: [], total: 0);
        }
        return CartApiModel.fromJson(data as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch cart');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<CartApiModel> addProduct({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.cartAddProduct,
        data: {'itemId': itemId, 'quantity': quantity},
      );
      if (response.data['success'] == true) {
        return CartApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Failed to add product');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<CartApiModel> removeItem(String refId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.cartRemoveItem(refId),
      );
      if (response.data['success'] == true) {
        return CartApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Failed to remove item');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<CartApiModel> updateQuantity({
    required String refId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.cartUpdateQuantity,
        data: {'refId': refId, 'quantity': quantity},
      );
      if (response.data['success'] == true) {
        return CartApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Failed to update quantity');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<CartApiModel> clearCart() async {
    try {
      final response = await _apiClient.dio.delete(ApiEndpoints.cartClear);
      if (response.data['success'] == true) {
        return CartApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Failed to clear cart');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }
}
