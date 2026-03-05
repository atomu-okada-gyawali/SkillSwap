import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/usecase.dart';
import 'package:skillswap/features/proposals/data/models/schedule_model.dart';
import 'package:skillswap/features/proposals/data/repositories/schedules_repository.dart';
import 'package:skillswap/features/proposals/domain/repositories/schedules_repository_interface.dart';

final createScheduleUsecaseProvider = Provider<CreateScheduleUsecase>((ref) {
  return CreateScheduleUsecase(
    repository: ref.read(schedulesRepositoryProvider),
  );
});

class CreateScheduleParams {
  final ScheduleModel schedule;

  CreateScheduleParams({required this.schedule});
}

class CreateScheduleUsecase
    implements UsecaseWithParams<ScheduleModel, CreateScheduleParams> {
  final ISchedulesRepository _repository;

  CreateScheduleUsecase({required ISchedulesRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ScheduleModel>> call(CreateScheduleParams params) async {
    return await _repository.createSchedule(params.schedule);
  }
}
