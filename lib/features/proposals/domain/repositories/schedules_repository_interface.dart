import 'package:dartz/dartz.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/proposals/domain/entities/schedule_entity.dart';

abstract interface class ISchedulesRepository {
  Future<Either<Failure, List<ScheduleEntity>>> getSchedules();
  Future<Either<Failure, ScheduleEntity>> getScheduleById(String id);
  Future<Either<Failure, ScheduleEntity>> createSchedule(
    ScheduleEntity schedule,
  );
  Future<Either<Failure, ScheduleEntity>> acceptSchedule(String id);
}
