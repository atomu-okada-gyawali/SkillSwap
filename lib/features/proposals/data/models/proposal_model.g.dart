// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalModel _$ProposalModelFromJson(Map<String, dynamic> json) =>
    ProposalModel(
      id: json['_id'] as String?,
      senderId: json['senderId'] == null
          ? null
          : AuthApiModel.fromJson(json['senderId'] as Map<String, dynamic>),
      receiverId: json['receiverId'] == null
          ? null
          : AuthApiModel.fromJson(json['receiverId'] as Map<String, dynamic>),
      postId: _postIdFromJson(json['postId']),
      offeredSkill: _offeredSkillFromJson(json['offeredSkill']),
      message: json['message'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProposalModelToJson(ProposalModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'postId': instance.postId,
      'offeredSkill': instance.offeredSkill,
      'message': instance.message,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'schedules': instance.schedules,
    };
