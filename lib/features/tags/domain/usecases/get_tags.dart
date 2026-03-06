import 'package:dartz/dartz.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/tags/domain/entities/tag.dart';
import 'package:skillswap/features/tags/domain/repositories/tag_repository.dart';

class GetTags {
  final ITagRepository _repository;

  GetTags(this._repository);

  Future<Either<Failure, List<Tag>>> call() async {
    return await _repository.getTags();
  }
}
