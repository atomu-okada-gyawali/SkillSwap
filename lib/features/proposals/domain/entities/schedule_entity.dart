import 'package:equatable/equatable.dart';

class ScheduleEntity extends Equatable {
  final String? id;
  final String proposalId;
  final DateTime proposedDate;
  final String proposedTime;
  final int durationMinutes;
  final bool accepted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleEntity({
    this.id,
    required this.proposalId,
    required this.proposedDate,
    required this.proposedTime,
    required this.durationMinutes,
    required this.accepted,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    proposalId,
    proposedDate,
    proposedTime,
    durationMinutes,
    accepted,
    createdAt,
    updatedAt,
  ];
}
