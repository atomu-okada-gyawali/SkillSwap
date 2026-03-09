import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/proposals/presentation/view_model/proposals_viewmodel.dart';
import 'package:skillswap/utils/my_colors.dart';

class ProposalDetailScreen extends ConsumerWidget {
  final String proposalId;

  const ProposalDetailScreen({super.key, required this.proposalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(proposalsViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;

    return proposalsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Proposal Details'),
          backgroundColor: MyColors.color4,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Proposal Details'),
          backgroundColor: MyColors.color4,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(proposalsViewModelProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (proposals) {
        final proposal = proposals.where((p) => p.id == proposalId);

        if (proposal.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Proposal Details'),
              backgroundColor: MyColors.color4,
            ),
            body: const Center(child: Text('Proposal not found')),
          );
        }

        final selectedProposal = proposal.first;
        final isReceived = selectedProposal.receiver?.authId == currentUserId;
        final isPending = selectedProposal.status == 'pending';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Proposal Details'),
            backgroundColor: MyColors.color4,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with sender/receiver and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isReceived
                                ? 'From: ${selectedProposal.sender?.fullName ?? 'Unknown'}'
                                : 'To: ${selectedProposal.receiver?.fullName ?? 'Unknown'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusChip(selectedProposal.status),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Message
                const Text(
                  'Message',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedProposal.message,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Schedule Information
                if (selectedProposal.schedules != null &&
                    selectedProposal.schedules!.isNotEmpty) ...[
                  const Text(
                    'Schedule Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...selectedProposal.schedules!
                      .map(
                        (schedule) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: schedule.accepted
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Date: ${_formatDate(schedule.proposedDate)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: schedule.accepted
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Time: ${schedule.proposedTime}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.hourglass_bottom,
                                      size: 20,
                                      color: schedule.accepted
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Duration: ${schedule.durationMinutes} minutes',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: schedule.accepted
                                            ? Colors.green
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        schedule.accepted
                                            ? 'Accepted'
                                            : 'Pending',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 24),
                ],

                // Skill Offered
                const Text(
                  'Skill Offered',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder<PostEntity?>(
                  future: ref
                      .read(proposalsViewModelProvider.notifier)
                      .getPostById(selectedProposal.offeredSkillId!),
                  builder: (context, snapshot) {
                    final title = switch (snapshot.connectionState) {
                      ConnectionState.waiting => 'Loading...',
                      ConnectionState.done =>
                        snapshot.data?.title ?? 'Not specified',
                      _ => 'Not specified',
                    };

                    return Text(title, style: const TextStyle(fontSize: 16));
                  },
                ),
                const SizedBox(height: 24),

                // Related Post
                if (selectedProposal.postId != null) ...[
                  const Text(
                    'Related Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<PostEntity?>(
                    future: ref
                        .read(proposalsViewModelProvider.notifier)
                        .getPostById(selectedProposal.postId!),
                    builder: (context, snapshot) {
                      final post = snapshot.data;

                      // If post is null and we have an error, it might be deleted
                      if (snapshot.hasError &&
                          snapshot.error.toString().contains('not found')) {
                        return Card(
                          child: ListTile(
                            title: const Text('Post not available'),
                            subtitle: const Text(
                              'This post may have been deleted',
                            ),
                            leading: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                // Refresh the proposals to get updated data
                                // ignore: unused_result
                                ref.refresh(proposalsViewModelProvider.future);
                              },
                              child: const Text('Refresh'),
                            ),
                          ),
                        );
                      }

                      return Card(
                        child: ListTile(
                          title: Text(post?.title ?? 'Loading...'),
                          subtitle: post != null
                              ? Text(
                                  post.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : const Text('Loading post details...'),
                          leading:
                              post != null &&
                                  post.postPhoto != null &&
                                  post.postPhoto!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${ApiEndpoints.baseUrl}${post.postPhoto}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 20,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 20,
                                  ),
                                ),
                          trailing: post != null
                              ? const Icon(Icons.arrow_forward_ios, size: 16)
                              : const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                          onTap: post != null
                              ? () {
                                  // TODO: Navigate to post details
                                  // For now, we'll just show a message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Post details navigation coming soon!',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                if (isReceived && isPending) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleAccept(context, ref),
                          icon: const Icon(Icons.check_circle, size: 20),
                          label: const Text('Accept Proposal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleReject(context, ref),
                          icon: const Icon(Icons.cancel, size: 20),
                          label: const Text('Reject Proposal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '⚠️ Once you accept or reject, this action cannot be undone.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (isReceived && !isPending) ...[
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedProposal.status == 'accepted'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedProposal.status == 'accepted'
                            ? Colors.green
                            : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectedProposal.status == 'accepted'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: selectedProposal.status == 'accepted'
                              ? Colors.green
                              : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedProposal.status == 'accepted'
                              ? 'Proposal Accepted'
                              : 'Proposal Rejected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: selectedProposal.status == 'accepted'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!isReceived) ...[
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Proposal Sent',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Waiting for the other person to respond',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAccept(BuildContext context, WidgetRef ref) async {
    await ref
        .read(proposalsViewModelProvider.notifier)
        .acceptProposal(proposalId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Proposal accepted!')));
      Navigator.pop(context);
    }
  }

  void _handleReject(BuildContext context, WidgetRef ref) async {
    await ref
        .read(proposalsViewModelProvider.notifier)
        .rejectProposal(proposalId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Proposal rejected!')));
      Navigator.pop(context);
    }
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'pending'
        ? Colors.orange
        : status == 'accepted'
        ? Colors.green
        : Colors.red;

    final text = status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
