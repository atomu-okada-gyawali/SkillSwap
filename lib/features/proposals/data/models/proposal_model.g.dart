// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalModel _$ProposalModelFromJson(Map<String, dynamic> json) =>
    ProposalModel(
      id: json['_id'] as String?,
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String?,
      postId: json['postId'] as String?,
      offeredSkill: json['offeredSkill'] as String?,
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      sender: json['sender'] == null
          ? null
          : AuthApiModel.fromJson(json['sender'] as Map<String, dynamic>),
      receiver: json['receiver'] == null
          ? null
          : AuthApiModel.fromJson(json['receiver'] as Map<String, dynamic>),
      post: json['post'] == null
          ? null
          : PostModel.fromJson(json['post'] as Map<String, dynamic>),
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
      'sender': instance.sender,
      'receiver': instance.receiver,
      'post': instance.post,
    };
