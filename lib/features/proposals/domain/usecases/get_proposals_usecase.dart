import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';

import 'package:skillswap/features/proposals/data/models/proposal_model.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';
import 'package:skillswap/features/proposals/domain/repositories/proposals_repository_interface.dart';

final getProposalsUsecaseProvider = Provider<GetProposalsUsecase>((ref) {
  return GetProposalsUsecase(
    repository: ref.read(proposalsRepositoryProvider),
  );
});

class GetProposalsUsecase
    implements UsecaseWithoutParams<List<ProposalModel>> {
  final IProposalsRepository _repository;

  GetProposalsUsecase({required IProposalsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ProposalModel>>> call() async {
    return await _repository.getProposals();
  }
}
