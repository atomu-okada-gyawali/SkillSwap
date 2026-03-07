import 'package:json_annotation/json_annotation.dart';
import 'package:skillswap/features/auth/data/models/auth_api_model.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/tags/data/models/tag_model.dart';

part 'post_model.g.dart';

/// Custom converter to handle userId as either String or Map<String, dynamic>
String? _userIdFromJson(dynamic json) {
  if (json is String) {
    return json;
  } else if (json is Map<String, dynamic>) {
    return json['_id'] as String?;
  }
  return null;
}

@JsonSerializable()
class PostModel {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'userId', fromJson: _userIdFromJson)
  final String? userId;
  final String title;
  final String description;
  @JsonKey(name: 'postPhoto')
  final String? postPhoto;
  final List<String> requirements;
  final TagModel? tag;
  @JsonKey(name: 'locationType')
  final String locationType;
  final String availability;
  final String? duration;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final AuthApiModel? user;

  PostModel({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    this.postPhoto,
    this.requirements = const [],
    this.tag,
    this.locationType = 'remote',
    this.availability = 'flexible',
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // First, try to get the generated model
    final model = _$PostModelFromJson(json);

    // If user is null but userId is a Map (embedded user), parse it
    if (model.user == null && json['userId'] is Map<String, dynamic>) {
      try {
        final userObject = AuthApiModel.fromJson(
          json['userId'] as Map<String, dynamic>,
        );
        // Return a new instance with the user populated
        return PostModel(
          id: model.id,
          userId: model.userId,
          title: model.title,
          description: model.description,
          postPhoto: model.postPhoto,
          requirements: model.requirements,
          tag: model.tag,
          locationType: model.locationType,
          availability: model.availability,
          duration: model.duration,
          createdAt: model.createdAt,
          updatedAt: model.updatedAt,
          user: userObject,
        );
      } catch (e) {
        // If parsing fails, return the original model
        return model;
      }
    }

    return model;
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
  PostEntity toEntity() {
    return PostEntity(
      id: id,
      title: title,
      description: description,
      postPhoto: postPhoto,
      requirements: requirements,
      tag: tag?.name ?? '',
      locationType: locationType,
      availability: availability,
      duration: duration,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: user?.username,
    );
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      postPhoto: entity.postPhoto,
      requirements: entity.requirements,
      tag: entity.tag.isNotEmpty ? TagModel(name: entity.tag) : null,
      locationType: entity.locationType,
      availability: entity.availability,
      duration: entity.duration,
    );
  }
}
