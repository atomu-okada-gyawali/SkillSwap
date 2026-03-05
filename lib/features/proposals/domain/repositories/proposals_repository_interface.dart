import 'package:dartz/dartz.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/proposals/data/models/proposal_model.dart';

abstract interface class IProposalsRepository {
  Future<Either<Failure, List<ProposalModel>>> getProposals();
  Future<Either<Failure, ProposalModel>> getProposalById(String id);
  Future<Either<Failure, ProposalModel>> createProposal(ProposalModel proposal);
  Future<Either<Failure, ProposalModel>> acceptProposal(String id);
  Future<Either<Failure, ProposalModel>> rejectProposal(String id);
}
