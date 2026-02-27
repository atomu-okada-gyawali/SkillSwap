import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/posts/data/models/post_model.dart';
import 'package:skillswap/features/posts/data/models/tag_model.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<PostModel>>(() {
  return PostsNotifier();
});

class PostsNotifier extends AsyncNotifier<List<PostModel>> {
  @override
  Future<List<PostModel>> build() async {
    return _fetchPosts();
  }

  Future<List<PostModel>> _fetchPosts() async {
    final repository = ref.read(postsRepositoryProvider);
    final result = await repository.getPosts();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPosts());
  }

  Future<void> createPost({
    required String title,
    required String description,
    required List<String> requirements,
    required List<String> tags,
    required String locationType,
    required String availability,
    String? duration,
    File? image,
  }) async {
    final repository = ref.read(postsRepositoryProvider);

    final result = await repository.createPostWithImage(
      title: title,
      description: description,
      requirements: requirements,
      tags: tags,
      locationType: locationType,
      availability: availability,
      duration: duration,
      image: image,
    );

    result.fold((failure) => throw Exception(failure.message), (post) {
      state = AsyncValue.data([...state.value ?? [], post]);
    });
  }

  Future<void> deletePost(String id) async {
    final repository = ref.read(postsRepositoryProvider);
    final result = await repository.deletePost(id);

    result.fold((failure) => throw Exception(failure.message), (success) {
      final currentPosts = state.value ?? [];
      state = AsyncValue.data(
        currentPosts.where((post) => post.id != id).toList(),
      );
    });
  }
}

final myPostsProvider = AsyncNotifierProvider<MyPostsNotifier, List<PostModel>>(
  () {
    return MyPostsNotifier();
  },
);

class MyPostsNotifier extends AsyncNotifier<List<PostModel>> {
  @override
  Future<List<PostModel>> build() async {
    return _fetchMyPosts();
  }

  Future<List<PostModel>> _fetchMyPosts() async {
    final repository = ref.read(postsRepositoryProvider);
    final result = await repository.getMyPosts();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMyPosts());
  }
}

final tagsProvider = AsyncNotifierProvider<TagsNotifier, List<TagModel>>(() {
  return TagsNotifier();
});

class TagsNotifier extends AsyncNotifier<List<TagModel>> {
  @override
  Future<List<TagModel>> build() async {
    return _fetchTags();
  }

  Future<List<TagModel>> _fetchTags() async {
    final repository = ref.read(postsRepositoryProvider);
    final result = await repository.getTags();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (tags) => tags,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTags());
  }
}

final selectedPostProvider = FutureProvider.family<PostModel, String>((
  ref,
  id,
) async {
  final repository = ref.read(postsRepositoryProvider);
  final result = await repository.getPostById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (post) => post,
  );
});
