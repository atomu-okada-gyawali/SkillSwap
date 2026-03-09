import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/domain/repositories/proposals_repository_interface.dart';

final getProposalsUsecaseProvider = Provider<GetProposalsUsecase>((ref) {
  return GetProposalsUsecase(repository: ref.read(proposalsRepositoryProvider));
});

class GetProposalsUsecase
    implements UsecaseWithParams<List<ProposalEntity>, GetProposalsParams> {
  final IProposalsRepository _repository;

  GetProposalsUsecase({required IProposalsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ProposalEntity>>> call(
    GetProposalsParams params,
  ) async {
    return await _repository.getProposals(
      userId: params.userId,
      page: params.page,
      size: params.size,
    );
  }
}

class GetProposalsParams {
  final String userId;
  final int page;
  final int size;

  GetProposalsParams({required this.userId, this.page = 1, this.size = 10});
}
