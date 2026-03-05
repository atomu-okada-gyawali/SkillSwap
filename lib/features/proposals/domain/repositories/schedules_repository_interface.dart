import 'package:dartz/dartz.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/proposals/data/models/schedule_model.dart';

abstract interface class ISchedulesRepository {
  Future<Either<Failure, List<ScheduleModel>>> getSchedules();
  Future<Either<Failure, ScheduleModel>> getScheduleById(String id);
  Future<Either<Failure, ScheduleModel>> createSchedule(ScheduleModel schedule);
  Future<Either<Failure, ScheduleModel>> acceptSchedule(String id);
}
