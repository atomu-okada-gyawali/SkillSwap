import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/domain/usecases/login_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/register_usecase.dart';
import 'package:skillswap/features/auth/presentation/state/auth_state.dart';


//provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);
class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = AuthState(status: AuthStatus.loading);
    final result = await _registerUsecase(
      RegisterUsecaseParams(
        username: username,
        email: email,
        password: password,
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
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = AuthState(status: AuthStatus.loading);
    final result = await _loginUsecase(
      LoginUsecaseParams(username: username, password: password),
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
}
