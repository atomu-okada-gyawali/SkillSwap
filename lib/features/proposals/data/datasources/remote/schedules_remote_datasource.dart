import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_client.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/core/services/storage/token_service.dart';
import 'package:skillswap/features/proposals/data/models/schedule_model.dart';

final schedulesRemoteDatasourceProvider = Provider<SchedulesRemoteDatasource>((
  ref,
) {
  return SchedulesRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class SchedulesRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  SchedulesRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  Future<List<ScheduleModel>> getSchedules() async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.schedules,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => ScheduleModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch schedules');
  }

  Future<ScheduleModel> getScheduleById(String id) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      '${ApiEndpoints.schedules}/$id',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ScheduleModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch schedule');
  }

  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.schedules,
      data: schedule.toJson(),
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ScheduleModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to create schedule');
  }

  Future<ScheduleModel> acceptSchedule(String id) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.patch(
      '${ApiEndpoints.schedules}/$id/accept',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ScheduleModel.fromJson(data);
    }
    throw Exception(
      response.data['message'] ?? 'Failed to accept schedule',
    );
  }
}
