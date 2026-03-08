import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/domain/repositories/posts_repository.dart';

class DeletePostParams extends Equatable {
  final String postId;

  const DeletePostParams({required this.postId});

  @override
  List<Object?> get props => [postId];
}

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  final postsRepository = ref.read(postsRepositoryProvider);
  return DeletePostUseCase(postsRepository: postsRepository);
});

class DeletePostUseCase implements UsecaseWithParams<bool, String> {
  final IPostsRepository _postsRepository;

  DeletePostUseCase({required IPostsRepository postsRepository})
    : _postsRepository = postsRepository;

  @override
  Future<Either<Failure, bool>> call(String postId) {
    return _postsRepository.deletePost(postId);
  }
}
