import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;
  static const String compIpAddress = '192.168.254.87';

  // Backend runs on port 5050 (from .env PORT=5050)
  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api';
    }
    if (kIsWeb) {
      return 'http://localhost:5050/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api';
    }
    return 'http://localhost:5050/api';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String whoAmI = '/auth/whoami';
  static const String updateProfile = '/auth/profile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // ─── Items ────────────────────────────────────────────────────────────────
  static const String items = '/items';
  static String itemById(String id) => '/items/$id';

  // ─── Cart ─────────────────────────────────────────────────────────────────
  static const String cart = '/cart';
  static const String cartAddProduct = '/cart/add-product';
  static String cartRemoveItem(String refId) => '/cart/remove/$refId';
  static const String cartUpdateQuantity = '/cart/update-quantity';
  static const String cartClear = '/cart/clear';

  // ─── Favorites ────────────────────────────────────────────────────────────
  static const String favorites = '/favorites';
  static const String favoritesAdd = '/favorites/add';
  static String favoritesRemove(String refId) => '/favorites/remove/$refId';

  // ─── Custom Bouquet ───────────────────────────────────────────────────────
  static const String customBouquets = '/custom-bouquets';

  // ─── Orders ───────────────────────────────────────────────────────────────
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  // ─── Notifications ────────────────────────────────────────────────────────
  static const String myNotifications = '/notifications/my';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static String clearNotification(String id) => '/notifications/$id/clear';
  static const String clearAllNotifications = '/notifications/clear-all';

  // ─── Static assets ────────────────────────────────────────────────────────
  // imageUrl from backend is already a full path like /uploads/uuid-name.jpg
  // Full image URL = imageBaseUrl + imageUrl
  static String get imageBaseUrl {
    if (isPhysicalDevice) return 'http://$compIpAddress:5050';
    if (kIsWeb) return 'http://localhost:5050';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:5050';
    return 'http://localhost:5050';
  }

  static String fullImageUrl(String imageUrl) => '$imageBaseUrl$imageUrl';
}
