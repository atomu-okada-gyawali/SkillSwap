import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/proposals/data/models/proposal_model.dart';
import 'package:skillswap/features/proposals/data/repositories/proposals_repository.dart';

final proposalsProvider =
    AsyncNotifierProvider<ProposalsNotifier, List<ProposalModel>>(() {
      return ProposalsNotifier();
    });

class ProposalsNotifier extends AsyncNotifier<List<ProposalModel>> {
  @override
  Future<List<ProposalModel>> build() async {
    return _fetchProposals();
  }

  Future<List<ProposalModel>> _fetchProposals() async {
    final repository = ref.read(proposalsRepositoryProvider);
    final result = await repository.getProposals();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (proposals) => proposals,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProposals());
  }

  Future<void> createProposal({
    required String receiverId,
    required String postId,
    required String offeredSkill,
    required String message,
  }) async {
    final repository = ref.read(proposalsRepositoryProvider);

    final proposal = ProposalModel(
      receiverId: receiverId,
      postId: postId,
      offeredSkill: offeredSkill,
      message: message,
    );

    final result = await repository.createProposal(proposal);

    result.fold((failure) => throw Exception(failure.message), (
      createdProposal,
    ) {
      state = AsyncValue.data([...state.value ?? [], createdProposal]);
    });
  }

  Future<void> acceptProposal(String id) async {
    final repository = ref.read(proposalsRepositoryProvider);
    final result = await repository.acceptProposal(id);

    result.fold((failure) => throw Exception(failure.message), (
      updatedProposal,
    ) {
      final currentProposals = state.value ?? [];
      state = AsyncValue.data(
        currentProposals.map((p) => p.id == id ? updatedProposal : p).toList(),
      );
    });
  }

  Future<void> rejectProposal(String id) async {
    final repository = ref.read(proposalsRepositoryProvider);
    final result = await repository.rejectProposal(id);

    result.fold((failure) => throw Exception(failure.message), (
      updatedProposal,
    ) {
      final currentProposals = state.value ?? [];
      state = AsyncValue.data(
        currentProposals.map((p) => p.id == id ? updatedProposal : p).toList(),
      );
    });
  }
}

final sentProposalsProvider = Provider<List<ProposalModel>>((ref) {
  final proposalsAsync = ref.watch(proposalsProvider);
  final authState = ref.watch(authViewModelProvider);
  final currentUserId = authState.authEntity?.authId;

  return proposalsAsync.maybeWhen(
    data: (proposals) =>
        proposals.where((p) => p.senderId == currentUserId).toList(),
    orElse: () => [],
  );
});

final receivedProposalsProvider = Provider<List<ProposalModel>>((ref) {
  final proposalsAsync = ref.watch(proposalsProvider);
  final authState = ref.watch(authViewModelProvider);
  final currentUserId = authState.authEntity?.authId;

  return proposalsAsync.maybeWhen(
    data: (proposals) =>
        proposals.where((p) => p.receiverId == currentUserId).toList(),
    orElse: () => [],
  );
});

final selectedProposalProvider = FutureProvider.family<ProposalModel, String>((
  ref,
  id,
) async {
  final repository = ref.read(proposalsRepositoryProvider);
  final result = await repository.getProposalById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (proposal) => proposal,
  );
});
