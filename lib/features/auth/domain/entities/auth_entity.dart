import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String email;
  final String username;
  final String? password;

  const AuthEntity({
    this.authId,
    required this.email,
    required this.username,
    this.password,
  });

  List<Object?> get props => [authId, email, username, password];
}
