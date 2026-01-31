import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LogoutUsecase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LogoutUsecase(authRepository: mockRepository);
  });

  group('LogoutUsecase', () {
    test('returns Right(true) when logout succeeds', () async {
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.call(null);

      expect(result.isRight(), isTrue);
      result.fold((l) => fail('expected right'), (r) => expect(r, isTrue));
    });

    test('returns Left(LocalDatabaseFailure) when logout fails', () async {
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => Left(LocalDatabaseFailure(message: 'failed')));

      final result = await usecase.call(null);

      expect(result.isLeft(), isTrue);
    });
  });
}
