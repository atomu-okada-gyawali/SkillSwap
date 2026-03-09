import 'package:dartz/dartz.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/tags/domain/entities/tag.dart';

abstract class ITagRepository {
  Future<Either<Failure, List<Tag>>> getTags();
}
