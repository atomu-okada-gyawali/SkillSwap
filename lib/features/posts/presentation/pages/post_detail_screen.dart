import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/posts/presentation/providers/posts_provider.dart';
import 'package:skillswap/features/posts/presentation/pages/edit_post_screen.dart';
import 'package:skillswap/features/proposals/presentation/pages/send_proposal_screen.dart';
import 'package:skillswap/utils/my_colors.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(selectedPostProvider(postId));
    final tagsAsync = ref.watch(tagsProvider);
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;

    final Map<String, String> tagMap = {};
    tagsAsync.whenData((tags) {
      for (var t in tags) {
        if (t.id != null) {
          tagMap[t.id!] = t.name;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: MyColors.color4,
        actions: [
          postAsync.whenOrNull(
                data: (post) {
                  if (post.userId == currentUserId) {
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditPostScreen(postId: postId),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteDialog(context, ref),
                        ),
                      ],
                    );
                  }
                  return null;
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: postAsync.when(
        data: (post) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.postPhoto != null && post.postPhoto!.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[200],
                  child: CachedNetworkImage(
                    imageUrl: post.postPhoto!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(),
                        const SizedBox(width: 8),
                        Text(
                          post.user?.username ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Location Type', post.locationType),
                    _buildDetailRow('Availability', post.availability),
                    if (post.duration != null && post.duration!.isNotEmpty)
                      _buildDetailRow('Duration', post.duration!),
                    const SizedBox(height: 16),
                    if (post.requirements.isNotEmpty) ...[
                      const Text(
                        'Requirements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.requirements
                            .map((req) => Chip(label: Text(req)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (post.tag.isNotEmpty) ...[
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.tag
                            .map(
                              (tagId) => Chip(
                                label: Text(tagMap[tagId] ?? tagId),
                                backgroundColor: MyColors.color2,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (post.userId != currentUserId)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SendProposalScreen(
                                  receiverId: post.userId!,
                                  postId: post.id!,
                                  receiverName:
                                      post.user?.username ?? 'Unknown',
                                  relatedPost: post,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.color5,
                            foregroundColor: MyColors.color1,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Send Proposal'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(selectedPostProvider(postId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(postsProvider.notifier).deletePost(postId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
