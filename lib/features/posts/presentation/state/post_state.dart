import 'package:equatable/equatable.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';

enum PostStatus { initial, loading, loaded, error, created, updated, deleted }

class PostState extends Equatable {
  final PostStatus status;
  final List<PostEntity> posts;
  final List<PostEntity> myPosts;
  final PostEntity? selectedPost;
  final String? errorMessage;
  final String? uploadedImageUrl;

  const PostState({
    this.status = PostStatus.initial,
    this.posts = const [],
    this.myPosts = const [],
    this.selectedPost,
    this.errorMessage,
    this.uploadedImageUrl,
  });

  PostState copyWith({
    PostStatus? status,
    List<PostEntity>? posts,
    List<PostEntity>? myPosts,
    PostEntity? selectedPost,
    bool resetSelectedPost = false,
    String? errorMessage,
    bool resetErrorMessage = false,
    String? uploadedImageUrl,
    bool resetUploadedImageUrl = false,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      myPosts: myPosts ?? this.myPosts,
      selectedPost: resetSelectedPost
          ? null
          : (selectedPost ?? this.selectedPost),
      errorMessage: resetErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      uploadedImageUrl: resetUploadedImageUrl
          ? null
          : (uploadedImageUrl ?? this.uploadedImageUrl),
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        myPosts,
        selectedPost,
        errorMessage,
        uploadedImageUrl,
      ];
}
