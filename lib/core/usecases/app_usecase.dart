import 'package:dartz/dartz.dart';
import 'package:skillswap/core/constants/failures.dart';

abstract interface class UsercaseWithParams<SuccessType,Params>{
  Future<Either<Failure, SuccessType>> call(Params params);
}

abstract interface class UsecaseWithoutParams<SuccessType,Params>{
  Future<Either<Failure, SuccessType>> createBatch(Params params);
}