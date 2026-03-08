import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/repositories/posts_repository.dart';
import 'dart:io';

// Create Post Parameters
class CreatePostParams extends Equatable {
  final String title;
  final String description;
  final List<String> requirements;
  final String? tag;
  final String locationType;
  final String availability;
  final String? duration;
  final File? image;

  const CreatePostParams({
    required this.title,
    required this.description,
    required this.requirements,
    this.tag,
    required this.locationType,
    required this.availability,
    this.duration,
    this.image,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    requirements,
    tag,
    locationType,
    availability,
    duration,
    image,
  ];
}

// Create Post Use Case Provider
final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  final postRepository = ref.read(postsRepositoryProvider);
  return CreatePostUseCase(postsRepository: postRepository);
});

// Create Post Use Case
class CreatePostUseCase implements UsecaseWithParams<void, CreatePostParams> {
  final IPostsRepository _postsRepository;

  CreatePostUseCase({required IPostsRepository postsRepository})
    : _postsRepository = postsRepository;

  @override
  Future<Either<Failure, void>> call(CreatePostParams params) {
    final postEntity = PostEntity(
      title: params.title,
      description: params.description,
      requirements: params.requirements,
      tag: params.tag,
      locationType: params.locationType,
      availability: params.availability,
      duration: params.duration,
    );
    return _postsRepository.createPost(postEntity, image: params.image);
  }
}
