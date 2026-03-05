import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/proposals/data/models/proposal_model.dart';
import 'package:skillswap/features/proposals/presentation/view_model/proposals_viewmodel.dart';
import 'package:skillswap/features/proposals/presentation/pages/proposal_detail_screen.dart';
import 'package:skillswap/utils/my_colors.dart';

class ProposalScreen extends ConsumerWidget {
  const ProposalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(proposalsViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;

    return DefaultTabController(
      length: 2,
      child: SizedBox.expand(
        child: Column(
          children: [
            Container(
              color: MyColors.color4,
              child: const TabBar(
                labelColor: MyColors.color1,
                unselectedLabelColor: MyColors.color2,
                indicatorColor: MyColors.color1,
                tabs: [
                  Tab(text: 'Sent'),
                  Tab(text: 'Received'),
                ],
              ),
            ),
            Expanded(
              child: proposalsAsync.when(
                data: (proposals) {
                  final sentProposals = proposals
                      .where((p) => p.senderId == currentUserId)
                      .toList();
                  final receivedProposals = proposals
                      .where((p) => p.receiverId == currentUserId)
                      .toList();

                  return TabBarView(
                    children: [
                      _buildProposalList(context, sentProposals, 'sent'),
                      _buildProposalList(
                        context,
                        receivedProposals,
                        'received',
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(proposalsViewModelProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalList(
    BuildContext context,
    List<ProposalModel> proposals,
    String type,
  ) {
    if (proposals.isEmpty) {
      return Center(
        child: Text(
          type == 'sent'
              ? 'No sent proposals yet'
              : 'No received proposals yet',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: proposals.length,
      itemBuilder: (context, index) {
        final proposal = proposals[index];
        return _ProposalCard(proposal: proposal, type: type);
      },
    );
  }
}

class _ProposalCard extends ConsumerWidget {
  final ProposalModel proposal;
  final String type;

  const _ProposalCard({required this.proposal, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = proposal.status == 'pending'
        ? Colors.orange
        : proposal.status == 'accepted'
        ? Colors.green
        : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProposalDetailScreen(proposalId: proposal.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type == 'sent'
                        ? 'To: ${proposal.receiver?.username ?? 'Unknown'}'
                        : 'From: ${proposal.sender?.username ?? 'Unknown'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      proposal.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                proposal.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Skill offered: ${proposal.offeredSkill ?? 'Not specified'}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
