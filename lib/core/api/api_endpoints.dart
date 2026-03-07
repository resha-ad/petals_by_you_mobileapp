import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const String _compIpAddress = '192.168.254.169';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Call this once at startup and cache the result
  static String? _baseUrl;

  static Future<void> init() async {
    _baseUrl = await _resolveBaseUrl();
  }

  static String get baseUrl {
    assert(_baseUrl != null, 'Call ApiEndpoints.init() in main() first');
    return _baseUrl!;
  }

  static Future<String> _resolveBaseUrl() async {
    if (kIsWeb) return 'http://localhost:5050/api';

    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final isEmulator = !info.isPhysicalDevice;
      return isEmulator
          ? 'http://10.0.2.2:5050/api'
          : 'http://$_compIpAddress:5050/api';
    }

    if (Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      final isEmulator = !info.isPhysicalDevice;
      return isEmulator
          ? 'http://localhost:5050/api'
          : 'http://$_compIpAddress:5050/api';
    }

    return 'http://localhost:5050/api';
  }

  // ─── keep imageBaseUrl in sync ────────────────────────────────────────────
  static String get imageBaseUrl {
    if (kIsWeb) return 'http://localhost:5050';
    // strip the /api suffix from baseUrl
    return baseUrl.replaceFirst('/api', '');
  }

  static String fullImageUrl(String imageUrl) => '$imageBaseUrl$imageUrl';

  // ─── All your existing endpoints unchanged ────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String whoAmI = '/auth/whoami';
  static const String updateProfile = '/auth/profile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  static const String items = '/items';
  static String itemById(String id) => '/items/$id';

  static const String cart = '/cart';
  static const String cartAddProduct = '/cart/add-product';
  static String cartRemoveItem(String refId) => '/cart/remove/$refId';
  static const String cartUpdateQuantity = '/cart/update-quantity';
  static const String cartClear = '/cart/clear';

  static const String favorites = '/favorites';
  static const String favoritesAdd = '/favorites/add';
  static String favoritesRemove(String refId) => '/favorites/remove/$refId';

  static const String customBouquets = '/custom-bouquets';

  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  static const String myNotifications = '/notifications/my';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static String clearNotification(String id) => '/notifications/$id/clear';
  static const String clearAllNotifications = '/notifications/clear-all';
}
