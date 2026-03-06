import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';

import 'package:skillswap/features/proposals/data/models/proposal_model.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';
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
    implements UsecaseWithParams<ProposalModel, RejectProposalParams> {
  final IProposalsRepository _repository;

  RejectProposalUsecase({required IProposalsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProposalModel>> call(RejectProposalParams params) async {
    return await _repository.rejectProposal(params.id);
  }
}
