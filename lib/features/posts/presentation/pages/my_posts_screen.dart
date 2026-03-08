import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/posts/presentation/view_model/posts_viewmodel.dart';
import 'package:skillswap/features/posts/presentation/widgets/my_post_card.dart';
import 'package:skillswap/features/posts/presentation/pages/post_detail_screen.dart';
import 'package:skillswap/features/posts/presentation/state/post_state.dart';
import 'package:skillswap/utils/my_colors.dart';

class MyPostsScreen extends ConsumerStatefulWidget {
  const MyPostsScreen({super.key});

  @override
  ConsumerState<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends ConsumerState<MyPostsScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool _hasBeenBuiltOnce = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Future.microtask(() {
        if (mounted) {
          ref.read(postsViewModelProvider.notifier).getMyPosts();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_hasBeenBuiltOnce) {
      _hasBeenBuiltOnce = true;
      Future.microtask(() {
        if (mounted) {
          ref.read(postsViewModelProvider.notifier).getMyPosts();
        }
      });
    }

    final postsState = ref.watch(postsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        backgroundColor: MyColors.color4,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(postsState),
    );
  }

  Widget _buildBody(PostState state) {
    switch (state.status) {
      case PostStatus.initial:
      case PostStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case PostStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Error loading posts',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(postsViewModelProvider.notifier).getMyPosts(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case PostStatus.loaded:
      case PostStatus.created:
      case PostStatus.updated:
      case PostStatus.deleted:
        if (state.myPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first post to get started!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(postsViewModelProvider.notifier).getMyPosts();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.myPosts.length,
            itemBuilder: (context, index) {
              final post = state.myPosts[index];

              return MyPostCard(
                post: post,
                onTap: () {
                  if (post.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostDetailScreen(postId: post.id!),
                      ),
                    );
                  }
                },
                onPostChanged: () {
                  ref.read(postsViewModelProvider.notifier).getMyPosts();
                },
              );
            },
          ),
        );
    }
  }
}
