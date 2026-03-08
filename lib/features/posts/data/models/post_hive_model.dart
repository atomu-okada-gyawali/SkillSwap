import 'package:hive/hive.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';

part 'post_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.postTypeId)
class PostHiveModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? postPhoto;

  @HiveField(4)
  final List<String> requirements;

  @HiveField(5)
  final String? tag;

  @HiveField(6)
  final String locationType;

  @HiveField(7)
  final String availability;

  @HiveField(8)
  final String? duration;

  @HiveField(9)
  final DateTime? createdAt;

  @HiveField(10)
  final DateTime? updatedAt;

  @HiveField(11)
  final String? userId;

  @HiveField(12)
  final String? username;

  @HiveField(13)
  final String? userProfilePicture;

  PostHiveModel({
    this.id,
    required this.title,
    required this.description,
    this.postPhoto,
    required this.requirements,
    this.tag,
    required this.locationType,
    required this.availability,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.username,
    this.userProfilePicture,
  });

  factory PostHiveModel.fromEntity(PostEntity entity) {
    return PostHiveModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      postPhoto: entity.postPhoto,
      requirements: entity.requirements,
      tag: entity.tag,
      locationType: entity.locationType,
      availability: entity.availability,
      duration: entity.duration,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
      username: entity.username,
      userProfilePicture: entity.userProfilePicture,
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      title: title,
      description: description,
      postPhoto: postPhoto,
      requirements: requirements,
      tag: tag,
      locationType: locationType,
      availability: availability,
      duration: duration,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      username: username,
      userProfilePicture: userProfilePicture,
    );
  }

  static List<PostEntity> toEntityList(List<PostHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
