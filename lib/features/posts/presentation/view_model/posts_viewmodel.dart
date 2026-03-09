import 'dart:io';

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/get_all_posts_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/get_my_posts_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/get_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/update_post_usecase.dart';
import 'package:skillswap/features/posts/presentation/state/post_state.dart';

final postsViewModelProvider = NotifierProvider<PostsViewModel, PostState>(
  PostsViewModel.new,
);

class PostsViewModel extends Notifier<PostState> {
  late final GetAllPostsUseCase _getAllPostsUseCase;
  late final GetMyPostsUseCase _getMyPostsUseCase;
  late final GetPostByIdUsecase _getPostByIdUseCase;
  late final CreatePostUseCase _createPostUseCase;
  late final UpdatePostUseCase _updatePostUseCase;
  late final DeletePostUseCase _deletePostUseCase;

  @override
  PostState build() {
    _getAllPostsUseCase = ref.read(getAllPostsUseCaseProvider);
    _getMyPostsUseCase = ref.read(getMyPostsUseCaseProvider);
    _getPostByIdUseCase = ref.read(getPostByIdUsecaseProvider);
    _createPostUseCase = ref.read(createPostUseCaseProvider);
    _updatePostUseCase = ref.read(updatePostUseCaseProvider);
    _deletePostUseCase = ref.read(deletePostUseCaseProvider);
    return const PostState();
  }

  Future<void> getAllPosts() async {
    state = state.copyWith(status: PostStatus.loading);

    final userId = ref.read(authViewModelProvider).authEntity?.authId ?? '';
    final result = await _getAllPostsUseCase(userId);
    result.fold(
      (failure) => state = state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      ),
      (posts) =>
          state = state.copyWith(status: PostStatus.loaded, posts: posts),
    );
  }

  Future<void> getPostById(String postId) async {
    state = state.copyWith(status: PostStatus.loading);

    final result = await _getPostByIdUseCase(GetPostByIdParams(postId: postId));
    result.fold(
      (failure) => state = state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      ),
      (post) =>
          state = state.copyWith(status: PostStatus.loaded, selectedPost: post),
    );
  }

  Future<void> getMyPosts() async {
    state = state.copyWith(status: PostStatus.loading);

    final result = await _getMyPostsUseCase();
    result.fold(
      (failure) => state = state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      ),
      (posts) {
        state = state.copyWith(status: PostStatus.loaded, myPosts: posts);
      },
    );
  }

  Future<void> createPost({
    required String title,
    required String description,
    required List<String> requirements,
    String? tag,
    required String locationType,
    required String availability,
    String? duration,
    File? image,
  }) async {
    state = state.copyWith(status: PostStatus.loading);

    final result = await _createPostUseCase(
      CreatePostParams(
        title: title,
        description: description,
        requirements: requirements,
        tag: tag,
        locationType: locationType,
        availability: availability,
        duration: duration,
        image: image,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(
          status: PostStatus.created,
          resetUploadedImageUrl: true,
        );
        getAllPosts();
      },
    );
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String description,
    required List<String> requirements,
    String? tag,
    required String locationType,
    required String availability,
    String? duration,
  }) async {
    state = state.copyWith(status: PostStatus.loading);

    final result = await _updatePostUseCase(
      UpdatePostParams(
        postId: postId,
        title: title,
        description: description,
        requirements: requirements,
        tag: tag,
        locationType: locationType,
        availability: availability,
        duration: duration,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: PostStatus.updated);
        getAllPosts();
      },
    );
  }

  Future<void> deletePost(String postId) async {
    state = state.copyWith(status: PostStatus.loading);

    final result = await _deletePostUseCase(postId);

    result.fold(
      (failure) => state = state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: PostStatus.deleted);
        getAllPosts();
      },
    );
  }

  Future<String?> uploadImage(File image) async {
    state = state.copyWith(status: PostStatus.loading);

    try {
      final url = '/uploads/postPhoto-${image.path.split('/').last}';
      state = state.copyWith(status: PostStatus.loaded, uploadedImageUrl: url);
      return url;
    } catch (e) {
      state = state.copyWith(
        status: PostStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(resetErrorMessage: true);
  }

  void clearSelectedPost() {
    state = state.copyWith(resetSelectedPost: true);
  }

  void clearCreateState() {
    state = state.copyWith(
      status: PostStatus.initial,
      resetUploadedImageUrl: true,
      resetErrorMessage: true,
    );
  }
}
