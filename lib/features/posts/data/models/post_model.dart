import 'package:json_annotation/json_annotation.dart';
import 'package:skillswap/features/auth/data/models/auth_api_model.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'userId')
  final String? userId;
  final String title;
  final String description;
  @JsonKey(name: 'postPhoto')
  final String? postPhoto;
  final List<String> requirements;
  final List<String> tag;
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
    this.tag = const [],
    this.locationType = 'remote',
    this.availability = 'flexible',
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? postPhoto,
    List<String>? requirements,
    List<String>? tag,
    String? locationType,
    String? availability,
    String? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthApiModel? user,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      postPhoto: postPhoto ?? this.postPhoto,
      requirements: requirements ?? this.requirements,
      tag: tag ?? this.tag,
      locationType: locationType ?? this.locationType,
      availability: availability ?? this.availability,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
