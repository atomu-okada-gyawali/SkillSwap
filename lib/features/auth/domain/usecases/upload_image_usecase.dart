import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/auth/data/repositories/auth_repository.dart';

//provider

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return UploadPhotoUsecase(repository: repository);
});

class UploadPhotoUsecase implements UsecaseWithParams<String, File> {
  final AuthRepository _repository;

  UploadPhotoUsecase({required AuthRepository repository}) : _repository = repository;
  @override
  Future<Either<Failure, String>> call(File params) {
    return _repository.uploadProfilePicture( params);
  }
}
