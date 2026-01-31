import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/auth/data/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: repository);
});

class GetCurrentUserUsecase implements UsecaseWithParams<AuthEntity, dynamic> {
  final IAuthRepository _repository;

  GetCurrentUserUsecase({required IAuthRepository authRepository})
    : _repository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(dynamic params) {
    return _repository.getCurrentUser();
  }
}
