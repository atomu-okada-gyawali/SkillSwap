import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/domain/entities/schedule_entity.dart';
import 'package:skillswap/features/proposals/presentation/view_model/proposals_viewmodel.dart';

class ProposalCard extends ConsumerWidget {
  final ProposalEntity proposal;
  final VoidCallback? onTap;

  const ProposalCard({super.key, required this.proposal, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with sender/receiver and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'From: ${proposal.sender?.username ?? 'Unknown'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildStatusChip(proposal.status),
                ],
              ),

              const SizedBox(height: 8),

              // Offered skill
              FutureBuilder<PostEntity?>(
                future: ref
                    .read(proposalsViewModelProvider.notifier)
                    .getPostById(proposal.offeredSkillId!),
                builder: (context, snapshot) {
                  final title = switch (snapshot.connectionState) {
                    ConnectionState.waiting => 'Loading...',
                    ConnectionState.done =>
                      snapshot.data?.title ?? 'Not available',
                    _ => 'Not available',
                  };

                  return Text(
                    'Offering: $title',
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Message preview
              Text(
                proposal.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 8),

              // Schedule info
              if (proposal.schedules != null && proposal.schedules!.isNotEmpty)
                _buildScheduleInfo(proposal.schedules!.first),

              const SizedBox(height: 8),

              // Timestamp
              Text(
                'Sent ${_formatDate(proposal.createdAt)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildScheduleInfo(ScheduleEntity schedule) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_formatDate(schedule.proposedDate)} at ${schedule.proposedTime} '
              '(${schedule.durationMinutes} min)',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
