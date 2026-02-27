import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/posts/data/models/post_model.dart';
import 'package:skillswap/features/proposals/presentation/providers/proposals_provider.dart';
import 'package:skillswap/utils/my_colors.dart';

class SendProposalScreen extends ConsumerStatefulWidget {
  final String receiverId;
  final String postId;
  final String receiverName;
  final PostModel? relatedPost;

  const SendProposalScreen({
    super.key,
    required this.receiverId,
    required this.postId,
    required this.receiverName,
    this.relatedPost,
  });

  @override
  ConsumerState<SendProposalScreen> createState() => _SendProposalScreenState();
}

class _SendProposalScreenState extends ConsumerState<SendProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _skillController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _sendProposal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(proposalsProvider.notifier)
          .createProposal(
            receiverId: widget.receiverId,
            postId: widget.postId,
            offeredSkill: _skillController.text.trim(),
            message: _messageController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal sent successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Proposal'),
        backgroundColor: MyColors.color4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sending proposal to:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.receiverName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.relatedPost != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Regarding:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.relatedPost!.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.relatedPost!.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'What skill can you offer in exchange?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _skillController,
                decoration: const InputDecoration(
                  labelText: 'Your skill',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Python programming, Guitar lessons',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a skill you can offer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Your message',
                  border: OutlineInputBorder(),
                  hintText:
                      'Introduce yourself and explain why you want to learn this skill...',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.color5,
                    foregroundColor: MyColors.color1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send Proposal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
