import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/services/connectivity/network_info.dart';
import 'package:skillswap/features/posts/data/datasources/remote/posts_remote_datasource.dart';
import 'package:skillswap/features/posts/data/models/post_model.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/repositories/posts_repository.dart';

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final postsRemoteDatasource = ref.read(postsRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return PostsRepository(
    postsRemoteDatasource: postsRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class PostsRepository implements IPostsRepository {
  final PostsRemoteDatasource _postsRemoteDatasource;
  final NetworkInfo _networkInfo;

  PostsRepository({
    required PostsRemoteDatasource postsRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _postsRemoteDatasource = postsRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<PostEntity>>> getAllPosts(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final posts = await _postsRemoteDatasource.getPosts();
        return Right(posts.map((model) => model.toEntity()).toList());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch posts',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getPostByUser(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final posts = await _postsRemoteDatasource.getMyPosts();
        return Right(posts.map((model) => model.toEntity()).toList());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to fetch user posts',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String itemId) async {
    if (await _networkInfo.isConnected) {
      try {
        final post = await _postsRemoteDatasource.getPostById(itemId);
        return Right(post.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch post',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> createPost(PostEntity item) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = PostModel.fromEntity(item);
        await _postsRemoteDatasource.createPost(model);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to create post',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePost(PostEntity item) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = PostModel.fromEntity(item);
        await _postsRemoteDatasource.updatePost(item.id!, model);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to update post',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePost(String itemId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _postsRemoteDatasource.deletePost(itemId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to delete post',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
