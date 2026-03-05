import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class ScheduleModel {
  @JsonKey(name: '_id')
  final String? id;
  final String proposalId;
  final DateTime proposedDate;
  final String proposedTime;
  final int durationMinutes;
  final bool accepted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScheduleModel({
    this.id,
    required this.proposalId,
    required this.proposedDate,
    required this.proposedTime,
    required this.durationMinutes,
    this.accepted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  ScheduleModel copyWith({
    String? id,
    String? proposalId,
    DateTime? proposedDate,
    String? proposedTime,
    int? durationMinutes,
    bool? accepted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      proposalId: proposalId ?? this.proposalId,
      proposedDate: proposedDate ?? this.proposedDate,
      proposedTime: proposedTime ?? this.proposedTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      accepted: accepted ?? this.accepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
