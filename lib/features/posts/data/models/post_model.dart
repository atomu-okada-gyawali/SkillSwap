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

/// Custom converter to handle tag field (can be String or Map)
TagModel? _tagFromJson(dynamic json) {
  if (json == null) return null;

  if (json is String) {
    return TagModel(id: json, name: json);
  }

  if (json is Map<String, dynamic>) {
    // Extract name from tag object
    final tagName = json['name'] as String?;
    final tagId = json['_id'] as String?;
    if (tagName != null) {
      return TagModel(id: tagId, name: tagName);
    }
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
  @JsonKey(fromJson: _tagFromJson)
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
    // Backend populates userId as a nested object: { _id, username, fullName, profilePicture }
    // First, parse using generated method
    final model = _$PostModelFromJson(json);

    // Extract user data from nested userId object
    if (json['userId'] is Map<String, dynamic>) {
      try {
        final userObject = AuthApiModel.fromJson(
          json['userId'] as Map<String, dynamic>,
        );
        print('DEBUG: ✓ Extracted user from userId: ${userObject.username}');

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
        print('DEBUG: ✗ Failed to parse user from userId: $e');
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
      userId: userId,
      username: user?.username,
      userProfilePicture: user?.profilePicture,
    );
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      postPhoto: entity.postPhoto,
      requirements: entity.requirements,
      tag: entity.tag?.isNotEmpty == true
          ? TagModel(id: entity.tag!, name: '')
          : null,
      locationType: entity.locationType,
      availability: entity.availability,
      duration: entity.duration,
    );
  }
}
