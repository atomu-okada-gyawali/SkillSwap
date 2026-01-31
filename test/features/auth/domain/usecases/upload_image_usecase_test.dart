import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/usecases/upload_image_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late UploadPhotoUsecase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = UploadPhotoUsecase(repository: mockRepository);
    registerFallbackValue(File('test/resources/dummy.png'));
  });

  group('UploadPhotoUsecase', () {
    final file = File('test/resources/dummy.png');

    test('returns Right(url) when repository succeeds', () async {
      when(
        () => mockRepository.uploadProfilePicture(file),
      ).thenAnswer((_) async => const Right('https://img.url'));

      final result = await usecase.call(file);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('expected right'),
        (r) => expect(r, contains('https://')),
      );
    });

    test('returns Left(ApiFailure) when repository fails', () async {
      when(
        () => mockRepository.uploadProfilePicture(file),
      ).thenAnswer((_) async => Left(ApiFailure(message: 'no internet')));

      final result = await usecase.call(file);

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ApiFailure>()),
        (r) => fail('expected left'),
      );
    });
  });
}
