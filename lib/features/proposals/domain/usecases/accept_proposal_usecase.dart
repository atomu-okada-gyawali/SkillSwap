import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/proposals/data/models/proposal_model.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';
import 'package:skillswap/features/proposals/domain/repositories/proposals_repository_interface.dart';

final acceptProposalUsecaseProvider = Provider<AcceptProposalUsecase>((ref) {
  return AcceptProposalUsecase(
    repository: ref.read(proposalsRepositoryProvider),
  );
});

class AcceptProposalParams {
  final String id;

  AcceptProposalParams({required this.id});
}

class AcceptProposalUsecase
    implements UsecaseWithParams<ProposalModel, AcceptProposalParams> {
  final IProposalsRepository _repository;

  AcceptProposalUsecase({required IProposalsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProposalModel>> call(AcceptProposalParams params) async {
    return await _repository.acceptProposal(params.id);
  }
}
