import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/domain/usecases/login_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/register_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:skillswap/features/auth/presentation/state/auth_state.dart';


final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final UploadPhotoUsecase _uploadPhotoUsecase;
  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String confirmPassword,
  }) async {
    state = AuthState(status: AuthStatus.loading);
    final result = await _registerUsecase(
      RegisterUsecaseParams(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        confirmPassword: confirmPassword,
      ),
    );

    result.fold(
      (failure) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = AuthState(status: AuthStatus.registered);
        }
      },
    );
  }

  //login
  Future<void> login({required String email, required String password}) async {
    state = AuthState(status: AuthStatus.loading);
    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = AuthState(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<void> uploadProfilePicture({required File photo}) async {
    state = state.copywith(status: AuthStatus.loading);
    final result = await _uploadPhotoUsecase(photo);
    result.fold(
      (failure) {
        state = state.copywith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (photoName) {
        state = state.copywith(
          status: AuthStatus.authenticated,
          uploadPhotoName: photoName,
        );
      },
    );
  }
}
