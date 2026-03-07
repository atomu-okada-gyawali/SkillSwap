import 'package:skillswap/core/config/environment_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Platform-aware configuration
  // Uses EnvironmentConfig to get the appropriate URL based on platformko
  static String baseUrl = EnvironmentConfig.getBaseUrl();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ auth Endpoints ============

  static const String userLogin = '/api/auth/login';
  static const String userRegister = '/api/auth/register';
  static const String userUploadProfile = '/api/auth/upload';
  static const String userUpdateProfile = '/api/auth/update-profile';

  // ============ Posts Endpoints ============

  static const String posts = '/api/posts';
  static String postById(String id) => '/api/posts/$id';
  static const String myPosts = '/api/posts/my-posts';
  static String deletePost(String id) => '/api/posts/$id';
  static String updatePost(String id) => '/api/posts/$id';
  static String createPost() => '/api/posts';
  // ============ Tags Endpoints ============

  static const String tags = '/api/tags';
  static String tagById(String id) => '/api/tags/$id';

  // ============ Proposals Endpoints ============

  static const String proposals = '/api/proposals';
  static String proposalById(String id) => '/api/proposals/$id';
  static String proposalStatus(String id) => '/api/proposals/$id/status';
  static String createProposal() => '/api/proposals/submit-complete';

  // ============ Schedules Endpoints ============

  static const String schedules = '/api/schedules';
  static String scheduleById(String id) => '/api/schedules/$id';
}
