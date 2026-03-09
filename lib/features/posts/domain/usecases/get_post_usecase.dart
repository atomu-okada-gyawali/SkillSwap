import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/repositories/posts_repository.dart';

class GetPostByIdParams extends Equatable {
  final String postId;

  const GetPostByIdParams({required this.postId});

  @override
  List<Object?> get props => [postId];
}

final getPostByIdUsecaseProvider = Provider<GetPostByIdUsecase>((ref) {
  final postsRepository = ref.read(postsRepositoryProvider);
  return GetPostByIdUsecase(postsRepository: postsRepository);
});

class GetPostByIdUsecase
    implements UsecaseWithParams<PostEntity, GetPostByIdParams> {
  final IPostsRepository _postsRepository;

  GetPostByIdUsecase({required IPostsRepository postsRepository})
    : _postsRepository = postsRepository;

  @override
  Future<Either<Failure, PostEntity>> call(GetPostByIdParams params) {
    return _postsRepository.getPostById(params.postId);
  }
}
