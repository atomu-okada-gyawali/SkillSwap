import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';

import 'package:skillswap/features/proposals/domain/entities/schedule_entity.dart';
import 'package:skillswap/features/proposals/data/repositories/schedules_repository.dart';
import 'package:skillswap/features/proposals/domain/repositories/schedules_repository_interface.dart';

final createScheduleUsecaseProvider = Provider<CreateScheduleUsecase>((ref) {
  return CreateScheduleUsecase(
    repository: ref.read(schedulesRepositoryProvider),
  );
});

class CreateScheduleParams {
  final ScheduleEntity schedule;

  CreateScheduleParams({required this.schedule});
}

class CreateScheduleUsecase
    implements UsecaseWithParams<ScheduleEntity, CreateScheduleParams> {
  final ISchedulesRepository _repository;

  CreateScheduleUsecase({required ISchedulesRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ScheduleEntity>> call(
    CreateScheduleParams params,
  ) async {
    return await _repository.createSchedule(params.schedule);
  }
}
