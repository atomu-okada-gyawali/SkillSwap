import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/features/posts/presentation/widgets/post_card.dart';
import 'package:skillswap/features/posts/presentation/widgets/tag.dart';
import 'package:skillswap/features/posts/presentation/widgets/welcome_card.dart';
import 'package:skillswap/features/posts/presentation/pages/post_detail_screen.dart';
import 'package:skillswap/features/posts/presentation/view_model/posts_viewmodel.dart';
import 'package:skillswap/features/posts/presentation/state/post_state.dart';
import 'package:skillswap/features/tags/presentation/providers/tags_provider.dart';
import 'package:skillswap/utils/my_colors.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(postsViewModelProvider.notifier).getAllPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsViewModelProvider);
    final tagsAsync = ref.watch(tagsProvider);

    return SizedBox.expand(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        color: MyColors.color1,
        child: Column(
          children: [
            const WelcomeCard(),
            SizedBox(
              height: 40,
              child: tagsAsync.when(
                data: (tags) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tags.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Tag(
                      imagePath: tags[index].tagImage ?? '',
                      title: tags[index].name,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(width: 8);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            ),
            Expanded(child: _buildPostsList(postsState)),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(PostState state) {
    switch (state.status) {
      case PostStatus.initial:
      case PostStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case PostStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${state.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(postsViewModelProvider.notifier).getAllPosts(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case PostStatus.loaded:
      case PostStatus.created:
      case PostStatus.updated:
      case PostStatus.deleted:
        if (state.posts.isEmpty) {
          return const Center(child: Text('No posts found'));
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
            childAspectRatio: 0.7,
          ),
          itemCount: state.posts.length,
          itemBuilder: (BuildContext context, int index) {
            final entity = state.posts[index];
            return PostCard(
              title: entity.title,
              author: entity.username ?? 'Unknown',
              tag: entity.tag?.isNotEmpty == true ? [entity.tag!] : [],
              imagePath:
                  entity.postPhoto != null && entity.postPhoto!.isNotEmpty
                  ? '${ApiEndpoints.baseUrl}${entity.postPhoto}'
                  : '',
              userProfilePicture:
                  entity.userProfilePicture != null &&
                      entity.userProfilePicture!.isNotEmpty
                  ? '${ApiEndpoints.baseUrl}${entity.userProfilePicture}'
                  : null,
              postId: entity.id,
              onTap: () {
                if (entity.id != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PostDetailScreen(postId: entity.id!),
                    ),
                  );
                }
              },
            );
          },
        );
    }
  }
}
