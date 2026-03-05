import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/usecase.dart';
import 'package:skillswap/features/proposals/data/models/proposal_model.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';
import 'package:skillswap/features/proposals/domain/repositories/proposals_repository_interface.dart';

final createProposalUsecaseProvider = Provider<CreateProposalUsecase>((ref) {
  return CreateProposalUsecase(
    repository: ref.read(proposalsRepositoryProvider),
  );
});

class CreateProposalParams {
  final ProposalModel proposal;

  CreateProposalParams({required this.proposal});
}

class CreateProposalUsecase
    implements UsecaseWithParams<ProposalModel, CreateProposalParams> {
  final IProposalsRepository _repository;

  CreateProposalUsecase({required IProposalsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProposalModel>> call(CreateProposalParams params) async {
    return await _repository.createProposal(params.proposal);
  }
}
