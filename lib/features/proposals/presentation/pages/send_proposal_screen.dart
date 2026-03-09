import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/features/posts/presentation/view_model/posts_viewmodel.dart';
import 'package:skillswap/features/posts/presentation/state/post_state.dart';
import 'package:skillswap/features/proposals/presentation/providers/proposals_provider.dart';
import 'package:skillswap/features/proposals/presentation/widgets/schedule_form.dart';
import 'package:skillswap/utils/my_colors.dart';

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
  bool _hasTriedLoadingPosts = false;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    setState(() {
      _hasTriedLoadingPosts = true;
    });
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
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: proposalsState.isLoading ? null : _submitProposal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.color5,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: proposalsState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Proposal'),
              ),
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
    final myPosts = postsState.myPosts;

    // Only show loading spinner if we haven't tried loading yet and status is loading
    if (!_hasTriedLoadingPosts && postsState.status == PostStatus.loading) {
      return const CircularProgressIndicator();
    }

    if (myPosts.isEmpty && postsState.status == PostStatus.error) {
      return Column(
        children: [
          Text('Error loading posts: ${postsState.errorMessage}'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadUserPosts, child: const Text('Retry')),
        ],
      );
    }

    if (myPosts.isEmpty) {
      if (postsState.status == PostStatus.loading) {
        return const CircularProgressIndicator();
      }
      return Column(
        children: [
          const Text('No posts available. Create a post first.'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadUserPosts,
            child: const Text('Refresh Posts'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedOfferedSkill,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select a post to offer',
      ),
      items: myPosts.map((post) {
        return DropdownMenuItem(value: post.id, child: Text(post.title));
      }).toList(),
      onChanged: (value) => setState(() => _selectedOfferedSkill = value),
      validator: (value) =>
          value == null ? 'Please select what you offer' : null,
    );
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields
    if (_selectedOfferedSkill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select what you offer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Enhanced date/time validation
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Check if date is in the past
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    if (selectedDay.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected date cannot be in the past'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if date is more than 1 year in the future
    final maxDate = today.add(const Duration(days: 365));
    if (selectedDay.isAfter(maxDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selected date cannot be more than 1 year in the future',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if time is at least 1 hour from now
    final bufferTime = now.add(const Duration(hours: 1));
    if (selectedDateTime.isBefore(bufferTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time at least 1 hour from now'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate duration
    if (_durationMinutes < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duration must be at least 15 minutes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate message
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (message.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message must be at least 10 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (message.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message must be less than 500 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // All validations passed, submit proposal
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    await ref
        .read(proposalsNotifierProvider.notifier)
        .submitProposal(
          receiverId: widget.receiverId,
          postId: widget.postId,
          offeredSkill: _selectedOfferedSkill!,
          message: message,
          proposedDate: dateStr,
          proposedTime: timeStr,
          durationMinutes: _durationMinutes,
        );

    final state = ref.read(proposalsNotifierProvider);
    if (state.error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
