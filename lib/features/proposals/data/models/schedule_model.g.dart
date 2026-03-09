// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    ScheduleModel(
      id: json['_id'] as String?,
      proposalId: json['proposalId'] as String,
      proposedDate: DateTime.parse(json['proposedDate'] as String),
      proposedTime: json['proposedTime'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      accepted: json['accepted'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ScheduleModelToJson(ScheduleModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'proposalId': instance.proposalId,
      'proposedDate': instance.proposedDate.toIso8601String(),
      'proposedTime': instance.proposedTime,
      'durationMinutes': instance.durationMinutes,
      'accepted': instance.accepted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
