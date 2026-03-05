import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/usecases/usecase.dart';
import 'package:skillswap/features/proposals/data/models/schedule_model.dart';
import 'package:skillswap/features/proposals/data/repositories/schedules_repository.dart';
import 'package:skillswap/features/proposals/domain/repositories/schedules_repository_interface.dart';

final getSchedulesUsecaseProvider = Provider<GetSchedulesUsecase>((ref) {
  return GetSchedulesUsecase(
    repository: ref.read(schedulesRepositoryProvider),
  );
});

class GetSchedulesUsecase
    implements UsecaseWithoutParams<List<ScheduleModel>> {
  final ISchedulesRepository _repository;

  GetSchedulesUsecase({required ISchedulesRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ScheduleModel>>> call() async {
    return await _repository.getSchedules();
  }
}
