import 'package:hive/hive.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/features/proposals/domain/entities/schedule_entity.dart';

part 'schedule_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.scheduleTypeId)
class ScheduleHiveModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String proposalId;

  @HiveField(2)
  final DateTime proposedDate;

  @HiveField(3)
  final String proposedTime;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final bool accepted;

  @HiveField(6)
  final DateTime? createdAt;

  @HiveField(7)
  final DateTime? updatedAt;

  ScheduleHiveModel({
    this.id,
    required this.proposalId,
    required this.proposedDate,
    required this.proposedTime,
    required this.durationMinutes,
    required this.accepted,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleHiveModel.fromEntity(ScheduleEntity entity) {
    return ScheduleHiveModel(
      id: entity.id,
      proposalId: entity.proposalId,
      proposedDate: entity.proposedDate,
      proposedTime: entity.proposedTime,
      durationMinutes: entity.durationMinutes,
      accepted: entity.accepted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ScheduleEntity toEntity() {
    return ScheduleEntity(
      id: id,
      proposalId: proposalId,
      proposedDate: proposedDate,
      proposedTime: proposedTime,
      durationMinutes: durationMinutes,
      accepted: accepted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<ScheduleEntity> toEntityList(List<ScheduleHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
