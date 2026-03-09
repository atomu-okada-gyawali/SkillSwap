import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_client.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/core/services/storage/token_service.dart';
import 'package:skillswap/features/tags/data/models/tag_model.dart';

final tagsRemoteDatasourceProvider = Provider<TagsRemoteDatasource>((ref) {
  return TagsRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class TagsRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  TagsRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  Future<List<TagModel>> getTags() async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.tags,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => TagModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch tags');
  }
}
