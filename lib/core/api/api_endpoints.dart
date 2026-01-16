import 'package:skillswap/core/config/environment_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Platform-aware configuration
  // Uses EnvironmentConfig to get the appropriate URL based on platformko
  static String baseUrl = EnvironmentConfig.getBaseUrl();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ auth Endpoints ============

  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
}