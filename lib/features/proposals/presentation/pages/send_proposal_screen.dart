import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/features/posts/presentation/view_model/posts_viewmodel.dart';
import 'package:skillswap/features/posts/presentation/state/post_state.dart';
import 'package:skillswap/features/proposals/presentation/providers/proposals_provider.dart';
import 'package:skillswap/features/proposals/presentation/widgets/schedule_form.dart';

class SendProposalScreen extends ConsumerStatefulWidget {
  final String postId;
  final String receiverId;

  const SendProposalScreen({
    super.key,
    required this.postId,
    required this.receiverId,
  });

  @override
  ConsumerState<SendProposalScreen> createState() => _SendProposalScreenState();
}

class _SendProposalScreenState extends ConsumerState<SendProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String? _selectedOfferedSkill;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationMinutes = 60;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    await ref.read(postsViewModelProvider.notifier).getMyPosts();
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsViewModelProvider);
    final proposalsState = ref.watch(proposalsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Send Proposal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'What You Offer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPostDropdown(postsState),
            const SizedBox(height: 16),
            const Text(
              'Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe your proposal...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                if (value.length < 10) {
                  return 'Message must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ScheduleForm(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              durationMinutes: _durationMinutes,
              onDateChanged: (date) => setState(() => _selectedDate = date),
              onTimeChanged: (time) => setState(() => _selectedTime = time),
              onDurationChanged: (duration) =>
                  setState(() => _durationMinutes = duration),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: proposalsState.isLoading ? null : _submitProposal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: proposalsState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send Proposal'),
            ),
            if (proposalsState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  proposalsState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostDropdown(PostState postsState) {
    if (postsState.status == PostStatus.loading) {
      return const CircularProgressIndicator();
    }

    if (postsState.status == PostStatus.error) {
      return Column(
        children: [
          Text('Error loading posts: ${postsState.errorMessage}'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadUserPosts, child: const Text('Retry')),
        ],
      );
    }

    final posts = postsState.myPosts;

    if (posts.isEmpty) {
      return const Text('No posts available. Create a post first.');
    }

    return DropdownButtonFormField<String>(
      value: _selectedOfferedSkill,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select a post to offer',
      ),
      items: posts.map((post) {
        return DropdownMenuItem(value: post.id, child: Text(post.title));
      }).toList(),
      onChanged: (value) => setState(() => _selectedOfferedSkill = value),
      validator: (value) =>
          value == null ? 'Please select what you offer' : null,
    );
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    await ref
        .read(proposalsNotifierProvider.notifier)
        .submitProposal(
          receiverId: widget.receiverId,
          postId: widget.postId,
          offeredSkill: _selectedOfferedSkill!,
          message: _messageController.text,
          proposedDate: dateStr,
          proposedTime: timeStr,
          durationMinutes: _durationMinutes,
        );

    final state = ref.read(proposalsNotifierProvider);
    if (state.error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposal sent successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
