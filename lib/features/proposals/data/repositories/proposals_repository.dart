import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/services/connectivity/network_info.dart';
import 'package:skillswap/features/proposals/data/datasources/remote/proposals_remote_datasource.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/domain/repositories/proposals_repository_interface.dart';

final proposalsRepositoryProvider = Provider<IProposalsRepository>((ref) {
  final proposalsRemoteDatasource = ref.read(proposalsRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return ProposalsRepository(
    proposalsRemoteDatasource: proposalsRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class ProposalsRepository implements IProposalsRepository {
  final ProposalsRemoteDatasource _proposalsRemoteDatasource;
  final NetworkInfo _networkInfo;

  ProposalsRepository({
    required ProposalsRemoteDatasource proposalsRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _proposalsRemoteDatasource = proposalsRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<ProposalEntity>>> getProposals({
    required String userId,
    int page = 1,
    int size = 10,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _proposalsRemoteDatasource.getProposals(
          userId: userId,
          page: page,
          size: size,
        );
        final entities = models.map((model) => model.toEntity()).toList();
        return Right(entities);
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

  @override
  Future<Either<Failure, ProposalEntity>> getProposalById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _proposalsRemoteDatasource.getProposalById(id);
        final entity = model.toEntity();
        return Right(entity);
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

  @override
  Future<Either<Failure, ProposalEntity>> submitCompleteProposal({
    required String receiverId,
    required String postId,
    required String offeredSkill,
    required String message,
    required String proposedDate,
    required String proposedTime,
    required int durationMinutes,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _proposalsRemoteDatasource.submitCompleteProposal(
          receiverId: receiverId,
          postId: postId,
          offeredSkill: offeredSkill,
          message: message,
          proposedDate: proposedDate,
          proposedTime: proposedTime,
          durationMinutes: durationMinutes,
        );
        final entity = model.toEntity();
        return Right(entity);
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

  @override
  Future<Either<Failure, ProposalEntity>> updateProposalStatus(
    String id,
    String status,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _proposalsRemoteDatasource.updateProposalStatus(
          id,
          status,
        );
        final entity = model.toEntity();
        return Right(entity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ??
                'Failed to update proposal status',
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

  @override
  Future<Either<Failure, void>> deleteProposal(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        await _proposalsRemoteDatasource.deleteProposal(id);
        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to delete proposal',
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
