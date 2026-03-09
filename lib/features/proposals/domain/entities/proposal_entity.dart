import 'package:equatable/equatable.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/proposals/domain/entities/schedule_entity.dart';

class ProposalEntity extends Equatable {
  final String? id;
  final AuthEntity? sender;
  final AuthEntity? receiver;
  final PostEntity? post;
  final PostEntity? offeredSkill;
  final String? postId; // Store post ID separately
  final String? offeredSkillId; // Store offered skill ID separately
  final String message;
  final String status;
  final List<ScheduleEntity>? schedules;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProposalEntity({
    this.id,
    this.sender,
    this.receiver,
    this.post,
    this.offeredSkill,
    this.postId,
    this.offeredSkillId,
    required this.message,
    required this.status,
    this.schedules,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    sender,
    receiver,
    post,
    offeredSkill,
    postId,
    offeredSkillId,
    message,
    status,
    schedules,
    createdAt,
    updatedAt,
  ];
}
