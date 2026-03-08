import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/repositories/posts_repository.dart';

final getMyPostsUseCaseProvider = Provider<GetMyPostsUseCase>((ref) {
  final postsRepository = ref.read(postsRepositoryProvider);
  return GetMyPostsUseCase(postsRepository: postsRepository);
});

class GetMyPostsUseCase implements UsecaseWithoutParams<List<PostEntity>> {
  final IPostsRepository _postsRepository;

  GetMyPostsUseCase({required IPostsRepository postsRepository})
    : _postsRepository = postsRepository;

  @override
  Future<Either<Failure, List<PostEntity>>> call() {
    return _postsRepository.getPostByUser('');
  }
}
