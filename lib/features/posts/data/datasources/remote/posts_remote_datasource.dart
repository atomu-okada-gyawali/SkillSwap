import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_client.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/core/services/storage/token_service.dart';
import 'package:skillswap/features/posts/data/models/post_model.dart';

final postsRemoteDatasourceProvider = Provider<PostsRemoteDatasource>((ref) {
  return PostsRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class PostsRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  PostsRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  Future<List<PostModel>> getPosts(String userId) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.posts,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
      queryParameters: {'excludeUserId': userId},
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      // Debug: Print the first post to see the structure
      if (data.isNotEmpty) {
        print('DEBUG: First post JSON: ${data.first}');
      }
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch posts');
  }

  Future<PostModel> getPostById(String id) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.postById(id),
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PostModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch post');
  }

  Future<List<PostModel>> getMyPosts() async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.myPosts,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch my posts');
  }

  Future<PostModel> createPost(PostModel post) async {
    final token = await _tokenService.getToken();
    final Map<String, dynamic> data = {
      'title': post.title,
      'description': post.description,
      'requirements': post.requirements,
      // backend expects tag to be a tag ID (string) or object; we send ID
      if (post.tag != null) 'tag': post.tag!.id,
      'locationType': post.locationType,
      'availability': post.availability,
      // send empty string instead of null for optional duration
      if (post.duration != null && post.duration!.isNotEmpty)
        'duration': post.duration,
    };

    final response = await _apiClient.post(
      ApiEndpoints.posts,
      data: data,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PostModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to create post');
  }

  Future<PostModel> updatePost(String id, PostModel post) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.put(
      ApiEndpoints.postById(id),
      data: post.toJson(),
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PostModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to update post');
  }

  Future<bool> deletePost(String id) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.delete(
      ApiEndpoints.postById(id),
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? 'Failed to delete post');
  }

  Future<PostModel> createPostWithImage({
    required String title,
    required String description,
    required List<String> requirements,
    required List<String> tags,
    required String locationType,
    required String availability,
    String? duration,
    File? image,
  }) async {
    final token = await _tokenService.getToken();

    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'requirements': requirements,
      'tag': tags,
      'locationType': locationType,
      'availability': availability,
      'duration': duration ?? '',
    });

    if (image != null) {
      formData.files.add(
        MapEntry(
          'postPhoto',
          MultipartFile.fromFileSync(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    final response = await _apiClient.uploadFile(
      ApiEndpoints.posts,
      formData: formData,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PostModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to create post');
  }
}
