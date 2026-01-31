import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late GetCurrentUserUsecase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUserUsecase(authRepository: mockRepository);
  });

  group('GetCurrentUserUsecase', () {
    test(
      'returns Right(AuthEntity) when repository has current user',
      () async {
        final entity = AuthEntity(
          authId: '2',
          fullName: 'Name',
          email: 'me@example.com',
          username: 'me',
        );
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => Right(entity));

        final result = await usecase.call(null);

        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('expected right'),
          (r) => expect(r.email, equals('me@example.com')),
        );
      },
    );

    test('returns Left(LocalDatabaseFailure) when no user', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => Left(LocalDatabaseFailure(message: 'none')));

      final result = await usecase.call(null);

      expect(result.isLeft(), isTrue);
    });
  });
}
