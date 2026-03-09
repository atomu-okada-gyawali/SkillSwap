import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/usecases/get_post_usecase.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/domain/usecases/accept_proposal_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/get_proposals_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/reject_proposal_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/submit_proposal_complete_usecase.dart';

final proposalsViewModelProvider =
    AsyncNotifierProvider<ProposalsViewModel, List<ProposalEntity>>(() {
      return ProposalsViewModel();
    });

class ProposalsViewModel extends AsyncNotifier<List<ProposalEntity>> {
  @override
  Future<List<ProposalEntity>> build() async {
    return _fetchProposals();
  }

  Future<PostEntity?> getPostById(String postId) async {
    final getPostUseCase = ref.read(getPostByIdUsecaseProvider);
    final result = await getPostUseCase(GetPostByIdParams(postId: postId));
    return result.fold((failure) => null, (post) => post);
  }

  Future<List<ProposalEntity>> _fetchProposals() async {
    final getProposals = ref.read(getProposalsUsecaseProvider);
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final result = await getProposals(
      GetProposalsParams(userId: currentUserId),
    );
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
    required String proposedDate,
    required String proposedTime,
    required int durationMinutes,
  }) async {
    final submitProposal = ref.read(submitProposalCompleteUsecaseProvider);

    final result = await submitProposal(
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

    result.fold((failure) => throw Exception(failure.message), (
      createdProposal,
    ) {
      state = AsyncValue.data([...state.value ?? [], createdProposal]);
    });
  }

  Future<void> acceptProposal(String id) async {
    final acceptProposal = ref.read(acceptProposalUsecaseProvider);
    final result = await acceptProposal(AcceptProposalParams(id: id));

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
    final rejectProposal = ref.read(rejectProposalUsecaseProvider);
    final result = await rejectProposal(RejectProposalParams(id: id));

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

// Helper providers for filtered lists
final sentProposalsProvider = Provider<List<ProposalEntity>>((ref) {
  final proposalsAsync = ref.watch(proposalsViewModelProvider);
  final authState = ref.watch(authViewModelProvider);
  final currentUserId = authState.authEntity?.authId;

  return proposalsAsync.maybeWhen(
    data: (proposals) =>
        proposals.where((p) => p.sender?.authId == currentUserId).toList(),
    orElse: () => [],
  );
});

final receivedProposalsProvider = Provider<List<ProposalEntity>>((ref) {
  final proposalsAsync = ref.watch(proposalsViewModelProvider);
  final authState = ref.watch(authViewModelProvider);
  final currentUserId = authState.authEntity?.authId;

  return proposalsAsync.maybeWhen(
    data: (proposals) =>
        proposals.where((p) => p.receiver?.authId == currentUserId).toList(),
    orElse: () => [],
  );
});

final selectedProposalProvider = FutureProvider.family<ProposalEntity, String>((
  ref,
  id,
) async {
  final currentProposals = ref.read(proposalsViewModelProvider).value;
  if (currentProposals != null) {
    try {
      final found = currentProposals.firstWhere((p) => p.id == id);
      return found;
    } catch (_) {}
  }

  final getProposals = ref.read(getProposalsUsecaseProvider);
  final authState = ref.read(authViewModelProvider);
  final currentUserId = authState.authEntity?.authId;

  if (currentUserId == null) {
    throw Exception('User not authenticated');
  }

  final result = await getProposals(GetProposalsParams(userId: currentUserId));
  return result.fold(
    (failure) => throw Exception(failure.message),
    (proposals) => proposals.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Proposal not found'),
    ),
  );
});
