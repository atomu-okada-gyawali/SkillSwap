import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/services/connectivity/network_info.dart';
import 'package:skillswap/features/tags/data/datasources/remote/tags_remote_datasource.dart';
import 'package:skillswap/features/tags/domain/entities/tag.dart';
import 'package:skillswap/features/tags/domain/repositories/tag_repository.dart';

final tagsRepositoryProvider = Provider<ITagRepository>((ref) {
  final tagsRemoteDatasource = ref.read(tagsRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return TagsRepository(
    tagsRemoteDatasource: tagsRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class TagsRepository implements ITagRepository {
  final TagsRemoteDatasource _tagsRemoteDatasource;
  final NetworkInfo _networkInfo;

  TagsRepository({
    required TagsRemoteDatasource tagsRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _tagsRemoteDatasource = tagsRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    if (await _networkInfo.isConnected) {
      try {
        final tagModels = await _tagsRemoteDatasource.getTags();
        final tags = tagModels
            .map(
              (model) => Tag(
                id: model.id,
                name: model.name,
                tagImage: model.tagImage,
                createdAt: model.createdAt,
                updatedAt: model.updatedAt,
              ),
            )
            .toList();
        return Right(tags);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch tags',
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
