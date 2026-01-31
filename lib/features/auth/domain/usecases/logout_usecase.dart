import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/auth/data/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LogoutUsecase(authRepository: repository);
});

class LogoutUsecase implements UsecaseWithParams<bool, dynamic> {
  final IAuthRepository _repository;

  LogoutUsecase({required IAuthRepository authRepository})
    : _repository = authRepository;

  @override
  Future<Either<Failure, bool>> call(dynamic params) {
    return _repository.logout();
  }
}
