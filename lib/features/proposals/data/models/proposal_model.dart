import 'package:json_annotation/json_annotation.dart';
import 'package:skillswap/features/auth/data/models/auth_api_model.dart';
import 'package:skillswap/features/proposals/data/models/schedule_model.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';

part 'proposal_model.g.dart';

/// Custom converter to handle postId - could be string or object
String _postIdFromJson(dynamic json) {
  if (json == null) return '';
  if (json is String) return json;
  if (json is Map<String, dynamic>) {
    // Extract ID from object if API returns populated data
    return json['_id'] as String? ?? '';
  }
  return '';
}

/// Custom converter to handle offeredSkill - could be string or object
String _offeredSkillFromJson(dynamic json) {
  if (json == null) return '';
  if (json is String) return json;
  if (json is Map<String, dynamic>) {
    // Extract ID from object if API returns populated data
    return json['_id'] as String? ?? '';
  }
  return '';
}

@JsonSerializable()
class ProposalModel {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'senderId')
  final AuthApiModel? senderId; // API returns populated object
  @JsonKey(name: 'receiverId')
  final AuthApiModel? receiverId; // API returns populated object
  @JsonKey(name: 'postId', fromJson: _postIdFromJson)
  final String postId; // API returns string or object
  @JsonKey(name: 'offeredSkill', fromJson: _offeredSkillFromJson)
  final String offeredSkill; // API returns string or object
  final String message;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ScheduleModel>? schedules;

  ProposalModel({
    this.id,
    this.senderId,
    this.receiverId,
    required this.postId,
    required this.offeredSkill,
    required this.message,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.schedules,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) =>
      _$ProposalModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalModelToJson(this);

  ProposalModel copyWith({
    String? id,
    AuthApiModel? senderId,
    AuthApiModel? receiverId,
    String? postId,
    String? offeredSkill,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ScheduleModel>? schedules,
  }) {
    return ProposalModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      postId: postId ?? this.postId,
      offeredSkill: offeredSkill ?? this.offeredSkill,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schedules: schedules ?? this.schedules,
    );
  }

  factory ProposalModel.fromEntity(ProposalEntity entity) {
    return ProposalModel(
      id: entity.id,
      senderId: entity.sender != null
          ? AuthApiModel.fromEntity(entity.sender!)
          : null,
      receiverId: entity.receiver != null
          ? AuthApiModel.fromEntity(entity.receiver!)
          : null,
      postId: entity.postId ?? entity.post?.id ?? '',
      offeredSkill: entity.offeredSkillId ?? entity.offeredSkill?.id ?? '',
      message: entity.message,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      schedules: entity.schedules
          ?.map((s) => ScheduleModel.fromEntity(s))
          .toList(),
    );
  }

  ProposalEntity toEntity() {
    return ProposalEntity(
      id: id,
      sender: senderId?.toEntity(),
      receiver: receiverId?.toEntity(),
      post: null, // Will be fetched separately when needed
      offeredSkill: null, // Will be fetched separately when needed
      postId: postId, // Store the ID
      offeredSkillId: offeredSkill, // Store the ID
      message: message,
      status: status,
      schedules: schedules?.map((s) => s.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
