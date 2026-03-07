// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'package:skillswap/features/proposals/data/models/proposal_model.dart';
// import 'package:skillswap/features/proposals/domain/usecases/accept_proposal_usecase.dart';
// import 'package:skillswap/features/proposals/domain/usecases/create_proposal_usecase.dart';
// import 'package:skillswap/features/proposals/domain/usecases/get_proposals_usecase.dart';
// import 'package:skillswap/features/proposals/domain/usecases/reject_proposal_usecase.dart';

// final proposalsViewModelProvider =
//     AsyncNotifierProvider<ProposalsViewModel, List<ProposalModel>>(() {
//       return ProposalsViewModel();
//     });

// class ProposalsViewModel extends AsyncNotifier<List<ProposalModel>> {
//   @override
//   Future<List<ProposalModel>> build() async {
//     return _fetchProposals();
//   }

//   Future<List<ProposalModel>> _fetchProposals() async {
//     final getProposals = ref.read(getProposalsUsecaseProvider);
//     final result = await getProposals();
//     return result.fold(
//       (failure) => throw Exception(failure.message),
//       (proposals) => proposals,
//     );
//   }

//   Future<void> refresh() async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() => _fetchProposals());
//   }

//   Future<void> createProposal({
//     required String receiverId,
//     required String postId,
//     required String offeredSkill,
//     required String message,
//   }) async {
//     final createProposal = ref.read(createProposalUsecaseProvider);

//     final proposal = ProposalModel(
//       receiverId: receiverId,
//       postId: postId,
//       offeredSkill: offeredSkill,
//       message: message,
//     );

//     final result = await createProposal(
//       CreateProposalParams(proposal: proposal),
//     );

//     result.fold((failure) => throw Exception(failure.message), (
//       createdProposal,
//     ) {
//       state = AsyncValue.data([...state.value ?? [], createdProposal]);
//     });
//   }

//   Future<void> acceptProposal(String id) async {
//     final acceptProposal = ref.read(acceptProposalUsecaseProvider);
//     final result = await acceptProposal(AcceptProposalParams(id: id));

//     result.fold((failure) => throw Exception(failure.message), (
//       updatedProposal,
//     ) {
//       final currentProposals = state.value ?? [];
//       state = AsyncValue.data(
//         currentProposals.map((p) => p.id == id ? updatedProposal : p).toList(),
//       );
//     });
//   }

//   Future<void> rejectProposal(String id) async {
//     final rejectProposal = ref.read(rejectProposalUsecaseProvider);
//     final result = await rejectProposal(RejectProposalParams(id: id));

//     result.fold((failure) => throw Exception(failure.message), (
//       updatedProposal,
//     ) {
//       final currentProposals = state.value ?? [];
//       state = AsyncValue.data(
//         currentProposals.map((p) => p.id == id ? updatedProposal : p).toList(),
//       );
//     });
//   }
// }

// // Helper providers for filtered lists
// final sentProposalsProvider = Provider<List<ProposalModel>>((ref) {
//   final proposalsAsync = ref.watch(proposalsViewModelProvider);
//   final authState = ref.watch(authViewModelProvider);
//   final currentUserId = authState.authEntity?.authId;

//   return proposalsAsync.maybeWhen(
//     data: (proposals) =>
//         proposals.where((p) => p.senderId == currentUserId).toList(),
//     orElse: () => [],
//   );
// });

// final receivedProposalsProvider = Provider<List<ProposalModel>>((ref) {
//   final proposalsAsync = ref.watch(proposalsViewModelProvider);
//   final authState = ref.watch(authViewModelProvider);
//   final currentUserId = authState.authEntity?.authId;

//   return proposalsAsync.maybeWhen(
//     data: (proposals) =>
//         proposals.where((p) => p.receiverId == currentUserId).toList(),
//     orElse: () => [],
//   );
// });

// final selectedProposalProvider = FutureProvider.family<ProposalModel, String>((
//   ref,
//   id,
// ) async {
//   // Try to find it in the current state first
//   final currentProposals = ref.read(proposalsViewModelProvider).value;
//   if (currentProposals != null) {
//     try {
//       final found = currentProposals.firstWhere((p) => p.id == id);
//       return found;
//     } catch (_) {
//       // If not found in cache, fall back to fetching manually (or we could expose a getting usecase for single ID)
//       // We don't have GetProposalByIdUsecase yet, but we can iterate the list from the remote
//     }
//   }
  
//   // As a fallback, since we only made getProposals (all), we fetch all and filter
//   // Alternatively, we should make GetProposalByIdUsecase. Let's create it later if really needed, 
//   // but for now relying on the cached state is usually sufficient for detail screens.
//   final getProposals = ref.read(getProposalsUsecaseProvider);
//   final result = await getProposals();
//   return result.fold(
//     (failure) => throw Exception(failure.message),
//     (proposals) => proposals.firstWhere((p) => p.id == id, orElse: () => throw Exception('Proposal not found')),
//   );
// });
