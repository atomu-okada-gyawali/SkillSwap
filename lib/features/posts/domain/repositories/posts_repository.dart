import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:skillswap/core/constants/failures.dart';

import 'package:skillswap/features/posts/domain/entities/post_entity.dart';

abstract interface class IPostsRepository {
  Future<Either<Failure, List<PostEntity>>> getAllPosts(String userId);
  Future<Either<Failure, List<PostEntity>>> getPostByUser(String userId);
  Future<Either<Failure, List<PostEntity>>> getMyPosts();
  Future<Either<Failure, PostEntity>> getPostById(String itemId);
  Future<Either<Failure, bool>> createPost(PostEntity item, {File? image});
  Future<Either<Failure, bool>> updatePost(PostEntity item);
  Future<Either<Failure, bool>> deletePost(String itemId);
}
