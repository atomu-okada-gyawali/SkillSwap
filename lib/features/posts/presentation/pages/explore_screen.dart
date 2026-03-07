import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/features/posts/presentation/widgets/post_card.dart';
import 'package:skillswap/features/posts/presentation/widgets/tag.dart';
import 'package:skillswap/features/posts/presentation/widgets/welcome_card.dart';
import 'package:skillswap/features/posts/presentation/pages/post_detail_screen.dart';
import 'package:skillswap/features/posts/presentation/view_model/posts_provider.dart';
import 'package:skillswap/features/tags/presentation/providers/tags_provider.dart';
import 'package:skillswap/utils/my_colors.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    final tagsAsync = ref.watch(tagsProvider);

    final Map<String, String> tagMap = {};
    tagsAsync.whenData((tags) {
      for (var t in tags) {
        if (t.id != null) {
          tagMap[t.id!] = t.name;
        }
      }
    });

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
            Expanded(
              child: postsAsync.when(
                data: (posts) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = posts[index];
                    return PostCard(
                      title: post.title,
                      author: post.user?.username ?? 'Unknown',
                      tag: post.tag != null ? [post.tag!.name] : [],
                      imagePath:
                          post.postPhoto != null && post.postPhoto!.isNotEmpty
                          ? '${ApiEndpoints.baseUrl}${post.postPhoto}'
                          : '',
                      userProfilePicture:
                          post.user?.profilePicture != null &&
                              post.user!.profilePicture!.isNotEmpty
                          ? '${ApiEndpoints.baseUrl}${post.user!.profilePicture}'
                          : null,
                      postId: post.id,
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
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(postsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
