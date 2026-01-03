import 'package:hive/hive.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String username;
  @HiveField(3)
  final String? password;

  AuthHiveModel({
    String? authId,
    required this.email,
    required this.username,
    required this.password,
  }) : authId = authId ?? Uuid().v4();

  //From entity

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      email: entity.email!,
      username: entity.username!,
      password: entity.password!,
    );
  }
  //to entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      email: email,
      username: username,
      password: password,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
