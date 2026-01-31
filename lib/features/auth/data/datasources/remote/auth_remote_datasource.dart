import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_client.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/core/services/storage/token_service.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';
import 'package:skillswap/features/auth/data/datasources/auth_datasource.dart';
import 'package:skillswap/features/auth/data/models/auth_api_model.dart';

final authRemoteProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;
  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;
  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      //Save to session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
        phoneNumber: user.phoneNumber,
        profilePicture: user.profilePicture, 
      );

      // save token

      final token = response.data['token'] as String;
      await _tokenService.saveToken(token);
      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: user.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }
    return user;
  }

  @override
  Future<String> uploadProfilePicture(File image) async {
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFileSync(
        image.path,
        filename: fileName,
      ),
    });
    //get token from token service
    final token = await _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.userUploadProfile,
      formData: formData,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    // Basic success check and clearer error handling
    if (response.data['success'] == true) {
      return response.data['data'].toString();
    }

    throw Exception(response.data['message'] ?? 'Upload failed');
  }
}
