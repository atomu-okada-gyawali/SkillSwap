import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUsecase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  group('LoginUsecase', () {
    final params = LoginUsecaseParams(email: 'e@example.com', password: 'p');

    test('returns Right(AuthEntity) when repository succeeds', () async {
      final entity = AuthEntity(
        authId: '1',
        fullName: 'Name',
        email: 'e@example.com',
        username: 'u',
      );
      when(
        () => mockRepository.login(params.email, params.password),
      ).thenAnswer((_) async => Right(entity));

      final result = await usecase.call(params);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('expected right'),
        (r) => expect(r.email, equals('e@example.com')),
      );
      verify(
        () => mockRepository.login(params.email, params.password),
      ).called(1);
    });

    test('returns Left(ApiFailure) when repository fails', () async {
      when(
        () => mockRepository.login(params.email, params.password),
      ).thenAnswer((_) async => Left(ApiFailure(message: 'bad')));

      final result = await usecase.call(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ApiFailure>()),
        (r) => fail('expected left'),
      );
    });
  });
}
