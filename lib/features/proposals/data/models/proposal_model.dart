import 'package:json_annotation/json_annotation.dart';
import 'package:skillswap/features/auth/data/models/auth_api_model.dart';
import 'package:skillswap/features/posts/data/models/post_model.dart';

part 'proposal_model.g.dart';

@JsonSerializable()
class ProposalModel {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'senderId')
  final String? senderId;
  @JsonKey(name: 'receiverId')
  final String? receiverId;
  @JsonKey(name: 'postId')
  final String? postId;
  final String? offeredSkill;
  final String message;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AuthApiModel? sender;
  final AuthApiModel? receiver;
  final PostModel? post;

  ProposalModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.postId,
    this.offeredSkill,
    this.message = '',
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.receiver,
    this.post,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) =>
      _$ProposalModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalModelToJson(this);

  ProposalModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? postId,
    String? offeredSkill,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthApiModel? sender,
    AuthApiModel? receiver,
    PostModel? post,
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
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      post: post ?? this.post,
    );
  }
}
