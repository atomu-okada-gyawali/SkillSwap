import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/domain/repositories/proposals_repository_interface.dart';

final rejectProposalUsecaseProvider = Provider<RejectProposalUsecase>((ref) {
  return RejectProposalUsecase(
    repository: ref.read(proposalsRepositoryProvider),
  );
});

class RejectProposalParams {
  final String id;

  RejectProposalParams({required this.id});
}

class RejectProposalUsecase
    implements UsecaseWithParams<ProposalEntity, RejectProposalParams> {
  final IProposalsRepository _repository;

  RejectProposalUsecase({required IProposalsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProposalEntity>> call(
    RejectProposalParams params,
  ) async {
    return await _repository.updateProposalStatus(params.id, 'rejected');
  }
}
