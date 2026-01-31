import 'package:equatable/equatable.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  registered,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final AuthEntity? authEntity;
  final String? uploadPhotoName;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.authEntity,
    this.uploadPhotoName,
  });

  //copywith
  AuthState copywith({
    AuthStatus? status,
    String? errorMessage,
    AuthEntity? authEntity,
    String? uploadPhotoName,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      authEntity: authEntity ?? this.authEntity,
      uploadPhotoName: uploadPhotoName ?? this.uploadPhotoName,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    authEntity,
    uploadPhotoName,
  ];
}
