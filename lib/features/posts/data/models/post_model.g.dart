// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      postPhoto: json['postPhoto'] as String?,
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tag: (json['tag'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      locationType: json['locationType'] as String? ?? 'remote',
      availability: json['availability'] as String? ?? 'flexible',
      duration: json['duration'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'postPhoto': instance.postPhoto,
      'requirements': instance.requirements,
      'tag': instance.tag,
      'locationType': instance.locationType,
      'availability': instance.availability,
      'duration': instance.duration,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
