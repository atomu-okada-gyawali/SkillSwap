import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/domain/repositories/proposals_repository_interface.dart';

final submitProposalCompleteUsecaseProvider =
    Provider<SubmitProposalCompleteUsecase>((ref) {
      return SubmitProposalCompleteUsecase(
        repository: ref.read(proposalsRepositoryProvider),
      );
    });

class SubmitProposalCompleteParams {
  final String receiverId;
  final String postId;
  final String offeredSkill;
  final String message;
  final String proposedDate;
  final String proposedTime;
  final int durationMinutes;

  SubmitProposalCompleteParams({
    required this.receiverId,
    required this.postId,
    required this.offeredSkill,
    required this.message,
    required this.proposedDate,
    required this.proposedTime,
    required this.durationMinutes,
  });
}

class SubmitProposalCompleteUsecase
    implements UsecaseWithParams<ProposalEntity, SubmitProposalCompleteParams> {
  final IProposalsRepository _repository;

  SubmitProposalCompleteUsecase({required IProposalsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProposalEntity>> call(
    SubmitProposalCompleteParams params,
  ) async {
    return await _repository.submitCompleteProposal(
      receiverId: params.receiverId,
      postId: params.postId,
      offeredSkill: params.offeredSkill,
      message: params.message,
      proposedDate: params.proposedDate,
      proposedTime: params.proposedTime,
      durationMinutes: params.durationMinutes,
    );
  }
}
