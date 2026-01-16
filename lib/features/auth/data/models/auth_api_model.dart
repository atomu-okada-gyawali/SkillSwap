import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? profilePicture;

  AuthApiModel({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.profilePicture,
  });

  // toJSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
      'profilePicture': profilePicture,
    };
  }

  // fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      username: json['username'],
      password: json['password'],
      profilePicture: json['profilePicture'],
    );
  }

  // toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      profilePicture: profilePicture,
    );
  }

  // fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  // toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
