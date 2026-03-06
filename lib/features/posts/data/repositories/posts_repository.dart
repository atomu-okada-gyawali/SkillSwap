import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/services/connectivity/network_info.dart';
import 'package:skillswap/features/posts/data/datasources/remote/posts_remote_datasource.dart';
import 'package:skillswap/features/posts/data/models/post_model.dart';

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final postsRemoteDatasource = ref.read(postsRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return PostsRepository(
    postsRemoteDatasource: postsRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class PostsRepository {
  final PostsRemoteDatasource _postsRemoteDatasource;
  final NetworkInfo _networkInfo;

  PostsRepository({
    required PostsRemoteDatasource postsRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _postsRemoteDatasource = postsRemoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, List<PostModel>>> getPosts() async {
    if (await _networkInfo.isConnected) {
      try {
        final posts = await _postsRemoteDatasource.getPosts();
        return Right(posts);
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

  Future<Either<Failure, PostModel>> getPostById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final post = await _postsRemoteDatasource.getPostById(id);
        return Right(post);
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

  Future<Either<Failure, List<PostModel>>> getMyPosts() async {
    if (await _networkInfo.isConnected) {
      try {
        final posts = await _postsRemoteDatasource.getMyPosts();
        return Right(posts);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch my posts',
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

  Future<Either<Failure, PostModel>> createPost(PostModel post) async {
    if (await _networkInfo.isConnected) {
      try {
        final createdPost = await _postsRemoteDatasource.createPost(post);
        return Right(createdPost);
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

  Future<Either<Failure, PostModel>> createPostWithImage({
    required String title,
    required String description,
    required List<String> requirements,
    required List<String> tags,
    required String locationType,
    required String availability,
    String? duration,
    File? image,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final createdPost = await _postsRemoteDatasource.createPostWithImage(
          title: title,
          description: description,
          requirements: requirements,
          tags: tags,
          locationType: locationType,
          availability: availability,
          duration: duration,
          image: image,
        );
        return Right(createdPost);
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

  Future<Either<Failure, PostModel>> updatePost(
    String id,
    PostModel post,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final updatedPost = await _postsRemoteDatasource.updatePost(id, post);
        return Right(updatedPost);
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

  Future<Either<Failure, bool>> deletePost(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _postsRemoteDatasource.deletePost(id);
        return Right(result);
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
