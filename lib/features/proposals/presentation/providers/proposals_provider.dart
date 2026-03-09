import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/services/connectivity/network_info.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/domain/usecases/accept_proposal_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/get_proposals_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/reject_proposal_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/submit_proposal_complete_usecase.dart';

final getProposalsUseCaseProvider = Provider<GetProposalsUsecase>((ref) {
  final repository = ref.watch(proposalsRepositoryProvider);
  return GetProposalsUsecase(repository: repository);
});

final submitProposalCompleteUseCaseProvider =
    Provider<SubmitProposalCompleteUsecase>((ref) {
      final repository = ref.watch(proposalsRepositoryProvider);
      return SubmitProposalCompleteUsecase(repository: repository);
    });

final acceptProposalUseCaseProvider = Provider<AcceptProposalUsecase>((ref) {
  final repository = ref.watch(proposalsRepositoryProvider);
  return AcceptProposalUsecase(repository: repository);
});

final rejectProposalUseCaseProvider = Provider<RejectProposalUsecase>((ref) {
  final repository = ref.watch(proposalsRepositoryProvider);
  return RejectProposalUsecase(repository: repository);
});

final proposalsNotifierProvider =
    StateNotifierProvider<ProposalsNotifier, ProposalsState>((ref) {
      final getProposalsUseCase = ref.watch(getProposalsUseCaseProvider);
      final submitProposalUseCase = ref.watch(
        submitProposalCompleteUseCaseProvider,
      );
      final acceptUseCase = ref.watch(acceptProposalUseCaseProvider);
      final rejectUseCase = ref.watch(rejectProposalUseCaseProvider);
      final networkInfo = ref.watch(networkInfoProvider);

      return ProposalsNotifier(
        getProposalsUseCase: getProposalsUseCase,
        submitProposalUseCase: submitProposalUseCase,
        acceptUseCase: acceptUseCase,
        rejectUseCase: rejectUseCase,
        networkInfo: networkInfo,
        ref: ref,
      );
    });

class ProposalsState {
  final List<ProposalEntity> proposals;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMorePages;

  const ProposalsState({
    this.proposals = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  ProposalsState copyWith({
    List<ProposalEntity>? proposals,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return ProposalsState(
      proposals: proposals ?? this.proposals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

class ProposalsNotifier extends StateNotifier<ProposalsState> {
  final GetProposalsUsecase getProposalsUseCase;
  final SubmitProposalCompleteUsecase submitProposalUseCase;
  final AcceptProposalUsecase acceptUseCase;
  final RejectProposalUsecase rejectUseCase;
  final NetworkInfo networkInfo;
  final Ref ref;

  ProposalsNotifier({
    required this.getProposalsUseCase,
    required this.submitProposalUseCase,
    required this.acceptUseCase,
    required this.rejectUseCase,
    required this.networkInfo,
    required this.ref,
  }) : super(const ProposalsState());

  Future<void> loadProposals({bool loadMore = false}) async {
    if (!await networkInfo.isConnected) {
      state = state.copyWith(error: 'No internet connection');
      return;
    }

    if (loadMore && !state.hasMorePages) return;

    state = state.copyWith(isLoading: true, error: null);

    final page = loadMore ? state.currentPage + 1 : 1;
    final authState = ref.read(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;

    if (currentUserId == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return;
    }

    final result = await getProposalsUseCase(
      GetProposalsParams(userId: currentUserId, page: page, size: 10),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (proposals) => state = state.copyWith(
        proposals: loadMore ? [...state.proposals, ...proposals] : proposals,
        isLoading: false,
        currentPage: page,
        hasMorePages: proposals.length == 10,
      ),
    );
  }

  Future<void> submitProposal({
    required String receiverId,
    required String postId,
    required String offeredSkill,
    required String message,
    required String proposedDate,
    required String proposedTime,
    required int durationMinutes,
  }) async {
    if (!await networkInfo.isConnected) {
      state = state.copyWith(error: 'No internet connection');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await submitProposalUseCase(
      SubmitProposalCompleteParams(
        receiverId: receiverId,
        postId: postId,
        offeredSkill: offeredSkill,
        message: message,
        proposedDate: proposedDate,
        proposedTime: proposedTime,
        durationMinutes: durationMinutes,
      ),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (proposal) => state = state.copyWith(
        proposals: [proposal, ...state.proposals],
        isLoading: false,
      ),
    );
  }

  Future<void> acceptProposal(String proposalId) async {
    if (!await networkInfo.isConnected) {
      state = state.copyWith(error: 'No internet connection');
      return;
    }

    final result = await acceptUseCase(AcceptProposalParams(id: proposalId));

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      updatedProposal,
    ) {
      final updatedProposals = state.proposals.map((proposal) {
        return proposal.id == updatedProposal.id ? updatedProposal : proposal;
      }).toList();

      state = state.copyWith(proposals: updatedProposals);
    });
  }

  Future<void> rejectProposal(String proposalId) async {
    if (!await networkInfo.isConnected) {
      state = state.copyWith(error: 'No internet connection');
      return;
    }

    final result = await rejectUseCase(RejectProposalParams(id: proposalId));

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      updatedProposal,
    ) {
      final updatedProposals = state.proposals.map((proposal) {
        return proposal.id == updatedProposal.id ? updatedProposal : proposal;
      }).toList();

      state = state.copyWith(proposals: updatedProposals);
    });
  }
}
