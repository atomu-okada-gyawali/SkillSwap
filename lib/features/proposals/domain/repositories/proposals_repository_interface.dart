import 'package:dartz/dartz.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';

abstract interface class IProposalsRepository {
  Future<Either<Failure, List<ProposalEntity>>> getProposals({
    required String userId,
    int page = 1,
    int size = 10,
  });
  Future<Either<Failure, ProposalEntity>> getProposalById(String id);
  Future<Either<Failure, ProposalEntity>> submitCompleteProposal({
    required String receiverId,
    required String postId,
    required String offeredSkill,
    required String message,
    required String proposedDate,
    required String proposedTime,
    required int durationMinutes,
  });
  Future<Either<Failure, ProposalEntity>> updateProposalStatus(
    String id,
    String status,
  );
  Future<Either<Failure, void>> deleteProposal(String id);
}
