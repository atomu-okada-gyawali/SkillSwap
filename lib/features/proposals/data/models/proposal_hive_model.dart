import 'package:hive/hive.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';

part 'proposal_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.proposalTypeId)
class ProposalHiveModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? senderId;

  @HiveField(2)
  final String? receiverId;

  @HiveField(3)
  final String postId;

  @HiveField(4)
  final String offeredSkillId;

  @HiveField(5)
  final String message;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final DateTime? createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  ProposalHiveModel({
    this.id,
    this.senderId,
    this.receiverId,
    required this.postId,
    required this.offeredSkillId,
    required this.message,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ProposalHiveModel.fromEntity(ProposalEntity entity) {
    return ProposalHiveModel(
      id: entity.id,
      senderId: entity.sender?.authId,
      receiverId: entity.receiver?.authId,
      postId: entity.postId ?? entity.post?.id ?? '',
      offeredSkillId: entity.offeredSkillId ?? entity.offeredSkill?.id ?? '',
      message: entity.message,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProposalEntity toEntity() {
    return ProposalEntity(
      id: id,
      postId: postId,
      offeredSkillId: offeredSkillId,
      message: message,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<ProposalEntity> toEntityList(List<ProposalHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
