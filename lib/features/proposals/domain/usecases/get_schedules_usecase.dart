import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/app_usecase.dart';
import 'package:skillswap/features/proposals/domain/entities/schedule_entity.dart';
import 'package:skillswap/features/proposals/data/repositories/schedules_repository.dart';
import 'package:skillswap/features/proposals/domain/repositories/schedules_repository_interface.dart';

final getSchedulesUsecaseProvider = Provider<GetSchedulesUsecase>((ref) {
  return GetSchedulesUsecase(repository: ref.read(schedulesRepositoryProvider));
});

class GetSchedulesUsecase
    implements UsecaseWithoutParams<List<ScheduleEntity>> {
  final ISchedulesRepository _repository;

  GetSchedulesUsecase({required ISchedulesRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ScheduleEntity>>> call() async {
    return await _repository.getSchedules();
  }
}
