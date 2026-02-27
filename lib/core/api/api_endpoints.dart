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
  static const String userUploadProfile = '/auth/upload';
  static const String userUpdateProfile = '/auth/update-profile';

  // ============ Posts Endpoints ============

  static const String posts = '/posts';
  static String postById(String id) => '/posts/$id';
  static const String myPosts = '/posts/my-posts';

  // ============ Tags Endpoints ============

  static const String tags = '/tags';

  // ============ Proposals Endpoints ============

  static const String proposals = '/proposals';
  static String proposalById(String id) => '/proposals/$id';
  static String proposalStatus(String id) => '/proposals/$id/status';

  // ============ Schedules Endpoints ============

  static const String schedules = '/schedules';
}
