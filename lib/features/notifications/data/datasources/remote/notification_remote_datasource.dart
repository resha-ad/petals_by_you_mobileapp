import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_client.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/notifications/data/models/notification_api_model.dart';

abstract interface class INotificationRemoteDatasource {
  Future<List<NotificationApiModel>> getMyNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> clearNotification(String id);
  Future<void> clearAll();
}

final notificationRemoteDatasourceProvider =
    Provider<INotificationRemoteDatasource>((ref) {
      return NotificationRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class NotificationRemoteDatasource implements INotificationRemoteDatasource {
  final ApiClient _apiClient;
  NotificationRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<NotificationApiModel>> getMyNotifications() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.myNotifications);
      if (response.data['success'] == true) {
        final raw = response.data['data'] as List<dynamic>? ?? [];
        return raw
            .map(
              (e) => NotificationApiModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception(
        response.data['message'] ?? 'Failed to fetch notifications',
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch(ApiEndpoints.markNotificationRead(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to mark as read');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.patch(ApiEndpoints.markAllNotificationsRead);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to mark all as read',
      );
    }
  }

  @override
  Future<void> clearNotification(String id) async {
    try {
      await _apiClient.dio.patch(ApiEndpoints.clearNotification(id));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to clear notification',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _apiClient.dio.patch(ApiEndpoints.clearAllNotifications);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to clear all');
    }
  }
}
