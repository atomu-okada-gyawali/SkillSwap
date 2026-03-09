import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/posts/presentation/view_model/posts_viewmodel.dart';
import 'package:skillswap/features/posts/presentation/state/post_state.dart';
import 'package:skillswap/features/posts/presentation/pages/edit_post_screen.dart';
import 'package:skillswap/features/proposals/presentation/pages/send_proposal_screen.dart';
import 'package:skillswap/features/tags/presentation/providers/tags_provider.dart';
import 'package:skillswap/utils/my_colors.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postsViewModelProvider.notifier).getPostById(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsViewModelProvider);
    final tagsAsync = ref.watch(tagsProvider);
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;

    final post = postsState.selectedPost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: MyColors.color4,
        actions: [
          if (post != null && post.userId == currentUserId)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPostScreen(postId: widget.postId),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(context),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(postsState, tagsAsync, currentUserId),
    );
  }

  Widget _buildBody(
    PostState postsState,
    AsyncValue tagsAsync,
    String? currentUserId,
  ) {
    switch (postsState.status) {
      case PostStatus.initial:
      case PostStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case PostStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${postsState.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(postsViewModelProvider.notifier)
                    .getPostById(widget.postId),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case PostStatus.loaded:
      case PostStatus.created:
      case PostStatus.updated:
      case PostStatus.deleted:
        final post = postsState.selectedPost;
        if (post == null) {
          return const Center(child: Text('Post not found'));
        }
        return _buildPostContent(post, currentUserId);
    }
  }

  Widget _buildPostContent(dynamic post, String? currentUserId) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.postPhoto != null && post.postPhoto!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              child: CachedNetworkImage(
                imageUrl: '${ApiEndpoints.baseUrl}${post.postPhoto}',
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
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          post.userProfilePicture != null &&
                              post.userProfilePicture!.isNotEmpty
                          ? CachedNetworkImageProvider(
                              '${ApiEndpoints.baseUrl}${post.userProfilePicture}',
                            )
                          : null,
                      child:
                          post.userProfilePicture == null ||
                              post.userProfilePicture!.isEmpty
                          ? const Icon(Icons.person, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.username ?? 'Unknown',
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(post.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text(
                  'Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                if (post.tag?.isNotEmpty == true) ...[
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(post.tag!),
                        backgroundColor: MyColors.color2,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                if (post.userId != currentUserId)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (post.userId == null || post.id == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SendProposalScreen(
                              receiverId: post.userId!,
                              postId: post.id!,
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(postsViewModelProvider.notifier)
                    .deletePost(widget.postId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
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
