import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? profilePicture;
  final String? confirmPassword;

  const AuthEntity({
    this.authId,
    required this.email,
    required this.username,
    this.password,
    required this.fullName,
    this.phoneNumber,
    this.profilePicture,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    phoneNumber,
    username,
    password,
    profilePicture,
    confirmPassword,
  ];
}
