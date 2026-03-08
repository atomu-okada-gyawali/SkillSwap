import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/auth/data/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/auth/domain/usecases/login_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/logout_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/register_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:skillswap/features/auth/presentation/state/auth_state.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeFile extends Fake implements File {}

class FakeRegisterParams extends Fake implements RegisterUsecaseParams {}

class FakeLoginParams extends Fake implements LoginUsecaseParams {}

void main() {
  late ProviderContainer container;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeFile());
    registerFallbackValue(null);
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockAuthRepository = MockAuthRepository();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        uploadPhotoUsecaseProvider.overrideWithValue(mockUploadPhotoUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel', () {
    group('register', () {
      test('sets status to loading then registered on success', () async {
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        await container
            .read(authViewModelProvider.notifier)
            .register(
              username: 'user',
              email: 'test@example.com',
              password: 'password',
              fullName: 'Test User',
              confirmPassword: 'password',
            );

        expect(
          container.read(authViewModelProvider).status,
          equals(AuthStatus.registered),
        );
        verify(() => mockRegisterUsecase(any())).called(1);
      });

      test('sets status to error with message on failure', () async {
        when(() => mockRegisterUsecase(any())).thenAnswer(
          (_) async => Left(ApiFailure(message: 'Registration failed')),
        );

        await container
            .read(authViewModelProvider.notifier)
            .register(
              username: 'user',
              email: 'test@example.com',
              password: 'password',
              fullName: 'Test User',
              confirmPassword: 'password',
            );

        expect(
          container.read(authViewModelProvider).status,
          equals(AuthStatus.error),
        );
        expect(
          container.read(authViewModelProvider).errorMessage,
          equals('Registration failed'),
        );
      });
    });

    group('login', () {
      test('sets status to loading then authenticated on success', () async {
        final authEntity = AuthEntity(
          authId: '1',
          fullName: 'Test User',
          email: 'test@example.com',
          username: 'user',
        );
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => Right(authEntity));

        await container
            .read(authViewModelProvider.notifier)
            .login(email: 'test@example.com', password: 'password');

        expect(
          container.read(authViewModelProvider).status,
          equals(AuthStatus.authenticated),
        );
        expect(
          container.read(authViewModelProvider).authEntity,
          equals(authEntity),
        );
        verify(() => mockLoginUsecase(any())).called(1);
      });

      test('sets status to error with message on failure', () async {
        when(() => mockLoginUsecase(any())).thenAnswer(
          (_) async => Left(ApiFailure(message: 'Invalid credentials')),
        );

        await container
            .read(authViewModelProvider.notifier)
            .login(email: 'test@example.com', password: 'wrong');

        expect(
          container.read(authViewModelProvider).status,
          equals(AuthStatus.error),
        );
        expect(
          container.read(authViewModelProvider).errorMessage,
          equals('Invalid credentials'),
        );
      });
    });

    group('uploadProfilePicture', () {
      test(
        'sets status to loading then authenticated with photo name on success',
        () async {
          when(
            () => mockUploadPhotoUsecase(any()),
          ).thenAnswer((_) async => const Right('profile_photo.jpg'));

          await container
              .read(authViewModelProvider.notifier)
              .uploadProfilePicture(photo: FakeFile());

          expect(
            container.read(authViewModelProvider).status,
            equals(AuthStatus.authenticated),
          );
          expect(
            container.read(authViewModelProvider).uploadPhotoName,
            equals('profile_photo.jpg'),
          );
        },
      );
    });

    group('logout', () {
      test('sets status to unauthenticated', () async {
        when(
          () => mockLogoutUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        await container.read(authViewModelProvider.notifier).logout();

        expect(
          container.read(authViewModelProvider).status,
          equals(AuthStatus.unauthenticated),
        );
        verify(() => mockLogoutUsecase(null)).called(1);
      });
    });

    group('updateProfile', () {
      test(
        'sets status to loading then authenticated with updated user on success',
        () async {
          final updatedUser = AuthEntity(
            authId: '1',
            fullName: 'Updated Name',
            email: 'test@example.com',
            username: 'user',
          );
          when(
            () => mockAuthRepository.updateProfile(any(), any(), any()),
          ).thenAnswer((_) async => Right(updatedUser));

          await container
              .read(authViewModelProvider.notifier)
              .updateProfile(fullName: 'Updated Name', profilePicture: null);

          expect(
            container.read(authViewModelProvider).status,
            equals(AuthStatus.authenticated),
          );
          expect(
            container.read(authViewModelProvider).authEntity,
            equals(updatedUser),
          );
        },
      );

      test('sets status to error with message on failure', () async {
        when(
          () => mockAuthRepository.updateProfile(any(), any(), any()),
        ).thenAnswer((_) async => Left(ApiFailure(message: 'Update failed')));

        await container
            .read(authViewModelProvider.notifier)
            .updateProfile(fullName: 'Updated Name', profilePicture: null);

        expect(
          container.read(authViewModelProvider).status,
          equals(AuthStatus.error),
        );
        expect(
          container.read(authViewModelProvider).errorMessage,
          equals('Update failed'),
        );
      });
    });
  });
}
