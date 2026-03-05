import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/proposals/presentation/view_model/proposals_viewmodel.dart';
import 'package:skillswap/utils/my_colors.dart';

class ProposalDetailScreen extends ConsumerWidget {
  final String proposalId;

  const ProposalDetailScreen({super.key, required this.proposalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalAsync = ref.watch(selectedProposalProvider(proposalId));
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Details'),
        backgroundColor: MyColors.color4,
      ),
      body: proposalAsync.when(
        data: (proposal) {
          final isReceived = proposal.receiverId == currentUserId;
          final isPending = proposal.status == 'pending';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isReceived
                          ? 'From: ${proposal.sender?.username ?? 'Unknown'}'
                          : 'To: ${proposal.receiver?.username ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _StatusBadge(status: proposal.status),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Message',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(proposal.message, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                const Text(
                  'Skill Offered',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  proposal.offeredSkill ?? 'Not specified',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                if (proposal.post != null) ...[
                  const Text(
                    'Related Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: Text(proposal.post!.title),
                      subtitle: Text(
                        proposal.post!.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (isReceived && isPending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleAccept(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleReject(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
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
                onPressed: () =>
                    ref.refresh(selectedProposalProvider(proposalId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAccept(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(proposalsViewModelProvider.notifier).acceptProposal(proposalId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Proposal accepted!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleReject(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(proposalsViewModelProvider.notifier).rejectProposal(proposalId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Proposal rejected!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'pending'
        ? Colors.orange
        : status == 'accepted'
        ? Colors.green
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
