import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/services/storage/token_service.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';
import 'package:skillswap/features/auth/data/models/auth_api_model.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/profile/domain/repositories/profile_repository.dart';
import 'package:skillswap/core/api/api_client.dart';
import 'package:skillswap/core/api/api_endpoints.dart';

class ProfileRepository implements IProfileRepository {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  ProfileRepository({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<Either<Failure, AuthEntity>> getProfile() async {
    try {
      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) {
        return const Left(
          ApiFailure(message: 'User not logged in', statusCode: 401),
        );
      }

      final user = AuthApiModel(
        id: userId,
        fullName: _userSessionService.getCurrentUserFullName() ?? '',
        email: _userSessionService.getCurrentUserEmail() ?? '',
        username: _userSessionService.getCurrentUserUsername() ?? '',
        phoneNumber: _userSessionService.getCurrentUserPhoneNumber(),
        profilePicture: _userSessionService.getCurrentUserProfilePicture(),
      );

      return Right(user.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile({
    String? fullName,
    String? username,
  }) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        return const Left(
          ApiFailure(message: 'User not logged in', statusCode: 401),
        );
      }

      final Map<String, dynamic> data = {};
      if (fullName != null) data['fullName'] = fullName;
      if (username != null) data['username'] = username;

      final response = await _apiClient.put(
        ApiEndpoints.userUpdateProfile,
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        final user = AuthApiModel.fromJson(userData);

        await _userSessionService.saveUserSession(
          userId: user.id!,
          email: user.email,
          fullName: user.fullName,
          username: user.username,
          phoneNumber: user.phoneNumber,
          profilePicture: user.profilePicture,
        );

        return Right(user.toEntity());
      }

      return Left(
        ApiFailure(message: response.data['message'] ?? 'Update failed'),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update profile',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File image) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        return const Left(
          ApiFailure(message: 'User not logged in', statusCode: 401),
        );
      }

      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'profilePicture': MultipartFile.fromFileSync(
          image.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.userUploadProfile,
        formData: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final imageName = response.data['data'].toString();

        await _userSessionService.saveUserSession(
          userId: _userSessionService.getCurrentUserId() ?? '',
          email: _userSessionService.getCurrentUserEmail() ?? '',
          fullName: _userSessionService.getCurrentUserFullName() ?? '',
          username: _userSessionService.getCurrentUserUsername() ?? '',
          phoneNumber: _userSessionService.getCurrentUserPhoneNumber(),
          profilePicture: imageName,
        );

        return Right(imageName);
      }

      return Left(
        ApiFailure(message: response.data['message'] ?? 'Upload failed'),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to upload profile picture',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
