import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/posts/data/models/post_model.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<PostModel>>(() {
  return PostsNotifier();
});

class PostsNotifier extends AsyncNotifier<List<PostModel>> {
  @override
  Future<List<PostModel>> build() async {
    return _fetchPosts();
  }

  Future<List<PostModel>> _fetchPosts() async {
    final userId = ref.read(authViewModelProvider).authEntity?.authId ?? '';
    final repository = ref.read(postsRepositoryProvider);
    final result = await repository.getAllPosts(userId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts.map((e) => PostModel.fromEntity(e)).toList(),
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
    required String? tag,
    required String locationType,
    required String availability,
    String? duration,
    File? image,
  }) async {
    final repository = ref.read(postsRepositoryProvider);

    final postEntity = PostEntity(
      title: title,
      description: description,
      requirements: requirements,
      tag: tag ?? '',
      locationType: locationType,
      availability: availability,
      duration: duration,
    );

    final result = await repository.createPost(postEntity);

    result.fold((failure) => throw Exception(failure.message), (success) {
      if (success) {
        refresh();
      }
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
    final userId = ref.read(authViewModelProvider).authEntity?.authId ?? '';
    final repository = ref.read(postsRepositoryProvider);
    final result = await repository.getPostByUser(userId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts.map((e) => PostModel.fromEntity(e)).toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMyPosts());
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
    (post) => PostModel.fromEntity(post),
  );
});
