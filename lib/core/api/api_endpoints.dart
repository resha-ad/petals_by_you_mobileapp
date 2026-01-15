class ApiEndpoints {
  ApiEndpoints._();

  // Change this to your real backend URL when ready
  static const String baseUrl =
      'http://10.0.2.2:3000/api/v1'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api/v1'; // iOS simulator / desktop

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String users = '/users';
  static const String userLogin = '/users/login';
  static String userById(String id) => '/users/$id';
}
