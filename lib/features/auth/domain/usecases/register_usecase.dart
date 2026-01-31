import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/auth/data/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String confirmPassword;

  const RegisterUsecaseParams({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [username, email, password];
}

//Provider for registerUsecase
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      email: params.email,
      username: params.username,
      password: params.password,
      fullName: params.fullName,
      confirmPassword: params.confirmPassword,
    );
    return _authRepository.register(entity);
  }
}
