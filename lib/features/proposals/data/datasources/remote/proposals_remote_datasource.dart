import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_client.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/core/services/storage/token_service.dart';
import 'package:skillswap/features/proposals/data/models/proposal_model.dart';

final proposalsRemoteDatasourceProvider = Provider<ProposalsRemoteDatasource>((
  ref,
) {
  return ProposalsRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ProposalsRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProposalsRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  Future<List<ProposalModel>> getProposals() async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.proposals,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => ProposalModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch proposals');
  }

  Future<ProposalModel> getProposalById(String id) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.proposalById(id),
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ProposalModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch proposal');
  }

  Future<ProposalModel> createProposal(ProposalModel proposal) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.proposals,
      data: proposal.toJson(),
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ProposalModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to create proposal');
  }

  Future<ProposalModel> updateProposalStatus(String id, String status) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.patch(
      ApiEndpoints.proposalStatus(id),
      data: {'status': status},
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ProposalModel.fromJson(data);
    }
    throw Exception(
      response.data['message'] ?? 'Failed to update proposal status',
    );
  }
}
