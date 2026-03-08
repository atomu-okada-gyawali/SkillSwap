import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/presentation/pages/proposal_detail_screen.dart';
import 'package:skillswap/features/proposals/presentation/view_model/proposals_viewmodel.dart';
import 'package:skillswap/features/proposals/presentation/widgets/proposal_card.dart';
import 'package:flutter/foundation.dart';

class ProposalsScreen extends ConsumerStatefulWidget {
  const ProposalsScreen({super.key});

  @override
  ConsumerState<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends ConsumerState<ProposalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshProposals() async {
    final viewModel = ref.read(proposalsViewModelProvider.notifier);
    await viewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final proposalsAsync = ref.watch(proposalsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProposalsList(proposalsAsync, isReceived: true),
          _buildProposalsList(proposalsAsync, isReceived: false),
        ],
      ),
    );
  }

  Widget _buildProposalsList(
    AsyncValue<List<ProposalEntity>> proposalsAsync, {
    required bool isReceived,
  }) {
    return proposalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: _refreshProposals,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (proposals) {
        final authState = ref.watch(authViewModelProvider);
        final currentUserId = authState.authEntity?.authId;

        final filteredProposals = proposals.where((proposal) {
          final senderId = proposal.sender?.authId;
          final receiverId = proposal.receiver?.authId;

          if (currentUserId == null) return false;
          final matches = isReceived
              ? receiverId == currentUserId
              : senderId == currentUserId;

          return matches;
        }).toList();

        if (filteredProposals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isReceived ? 'No received proposals' : 'No sent proposals',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshProposals,
          child: ListView.builder(
            itemCount: filteredProposals.length,
            itemBuilder: (context, index) {
              final proposal = filteredProposals[index];
              return ProposalCard(
                proposal: proposal,
                onTap: () {
                  final id = proposal.id;
                  if (id == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProposalDetailScreen(proposalId: id),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
