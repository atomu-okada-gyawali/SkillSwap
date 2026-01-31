import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUsecase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
    registerFallbackValue(
      AuthEntity(authId: 'f', fullName: 'f', email: 'f@f', username: 'f'),
    );
  });

  group('RegisterUsecase', () {
    final params = RegisterUsecaseParams(
      username: 'u',
      email: 'e@example.com',
      password: 'p',
      fullName: 'Full Name',
      confirmPassword: 'p',
    );

    test('returns Right(true) when repository succeeds', () async {
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.call(params);

      expect(result.isRight(), isTrue);
      expect(result, equals(const Right(true)));
      verify(() => mockRepository.register(any())).called(1);
    });

    test(
      'returns Left(LocalDatabaseFailure) when repository fails locally',
      () async {
        when(() => mockRepository.register(any())).thenAnswer(
          (_) async => Left(LocalDatabaseFailure(message: 'exists')),
        );

        final result = await usecase.call(params);

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) => expect(l, isA<LocalDatabaseFailure>()),
          (r) => fail('expected left'),
        );
      },
    );
  });
}
