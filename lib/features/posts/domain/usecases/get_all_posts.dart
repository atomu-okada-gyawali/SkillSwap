import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/repositories/posts_repository.dart';

final getAllPostsUsecaseProvider = Provider<GetAllPostsUsecase>((ref) {
  final postsRepository = ref.read(postsRepositoryProvider);
  return GetAllPostsUsecase(postsRepository: postsRepository);
});

class GetAllPostsUsecase
    implements UsecaseWithParams<List<PostEntity>, String> {
  final IPostsRepository _postsRepository;

  GetAllPostsUsecase({required IPostsRepository postsRepository})
    : _postsRepository = postsRepository;

  @override
  Future<Either<Failure, List<PostEntity>>> call(String userId) {
    return _postsRepository.getAllPosts(userId);
  }
}
