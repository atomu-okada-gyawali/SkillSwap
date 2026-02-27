import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/services/connectivity/network_info.dart';
import 'package:skillswap/features/proposals/data/datasources/remote/proposals_remote_datasource.dart';
import 'package:skillswap/features/proposals/data/models/proposal_model.dart';

final proposalsRepositoryProvider = Provider<ProposalsRepository>((ref) {
  final proposalsRemoteDatasource = ref.read(proposalsRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return ProposalsRepository(
    proposalsRemoteDatasource: proposalsRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class ProposalsRepository {
  final ProposalsRemoteDatasource _proposalsRemoteDatasource;
  final NetworkInfo _networkInfo;

  ProposalsRepository({
    required ProposalsRemoteDatasource proposalsRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _proposalsRemoteDatasource = proposalsRemoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, List<ProposalModel>>> getProposals() async {
    if (await _networkInfo.isConnected) {
      try {
        final proposals = await _proposalsRemoteDatasource.getProposals();
        return Right(proposals);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch proposals',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  Future<Either<Failure, ProposalModel>> getProposalById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final proposal = await _proposalsRemoteDatasource.getProposalById(id);
        return Right(proposal);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch proposal',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  Future<Either<Failure, ProposalModel>> createProposal(
    ProposalModel proposal,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final createdProposal = await _proposalsRemoteDatasource.createProposal(
          proposal,
        );
        return Right(createdProposal);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to create proposal',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  Future<Either<Failure, ProposalModel>> acceptProposal(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final proposal = await _proposalsRemoteDatasource.updateProposalStatus(
          id,
          'accepted',
        );
        return Right(proposal);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to accept proposal',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  Future<Either<Failure, ProposalModel>> rejectProposal(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final proposal = await _proposalsRemoteDatasource.updateProposalStatus(
          id,
          'rejected',
        );
        return Right(proposal);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to reject proposal',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
