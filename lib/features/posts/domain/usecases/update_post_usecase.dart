import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/repositories/posts_repository.dart';

// Update Post Use Case Provider
final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  final postsRepository = ref.read(postsRepositoryProvider);
  return UpdatePostUseCase(postsRepository: postsRepository);
});

// Update Post Use Case
class UpdatePostUseCase implements UsecaseWithParams<void, UpdatePostParams> {
  final IPostsRepository _postsRepository;

  UpdatePostUseCase({required IPostsRepository postsRepository})
    : _postsRepository = postsRepository;

  @override
  Future<Either<Failure, void>> call(UpdatePostParams params)  {
    final postEntity = PostEntity(
      id: params.postId,
      title: params.title,
      description: params.description,
      requirements: params.requirements,
      tag: params.tag,
      locationType: params.locationType,
      availability: params.availability,
      duration: params.duration,
    );

    return _postsRepository.updatePost(postEntity);
  }
} // Update Post Parameters

class UpdatePostParams {
  final String postId;
  final String title;
  final String description;
  final List<String> requirements;
  final String? tag;
  final String locationType;
  final String availability;
  final String? duration;

  UpdatePostParams({
    required this.postId,
    required this.title,
    required this.description,
    required this.requirements,
    this.tag,
    required this.locationType,
    required this.availability,
    this.duration,
  });
}
