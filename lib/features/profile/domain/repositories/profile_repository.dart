import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, AuthEntity>> getProfile();
  Future<Either<Failure, AuthEntity>> updateProfile({
    String? fullName,
    String? username,
  });
  Future<Either<Failure, String>> uploadProfilePicture(File image);
}
