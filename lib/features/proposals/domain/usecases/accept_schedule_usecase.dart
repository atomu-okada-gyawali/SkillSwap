import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/usecase.dart';
import 'package:skillswap/features/proposals/data/models/schedule_model.dart';
import 'package:skillswap/features/proposals/data/repositories/schedules_repository.dart';
import 'package:skillswap/features/proposals/domain/repositories/schedules_repository_interface.dart';

final acceptScheduleUsecaseProvider = Provider<AcceptScheduleUsecase>((ref) {
  return AcceptScheduleUsecase(
    repository: ref.read(schedulesRepositoryProvider),
  );
});

class AcceptScheduleParams {
  final String id;

  AcceptScheduleParams({required this.id});
}

class AcceptScheduleUsecase
    implements UsecaseWithParams<ScheduleModel, AcceptScheduleParams> {
  final ISchedulesRepository _repository;

  AcceptScheduleUsecase({required ISchedulesRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ScheduleModel>> call(AcceptScheduleParams params) async {
    return await _repository.acceptSchedule(params.id);
  }
}
