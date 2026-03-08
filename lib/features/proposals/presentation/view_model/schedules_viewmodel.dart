import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/proposals/domain/entities/schedule_entity.dart';
import 'package:skillswap/features/proposals/domain/usecases/accept_schedule_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/create_schedule_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/get_schedules_usecase.dart';

final schedulesViewModelProvider =
    AsyncNotifierProvider<SchedulesViewModel, List<ScheduleEntity>>(() {
      return SchedulesViewModel();
    });

class SchedulesViewModel extends AsyncNotifier<List<ScheduleEntity>> {
  @override
  Future<List<ScheduleEntity>> build() async {
    return _fetchSchedules();
  }

  Future<List<ScheduleEntity>> _fetchSchedules() async {
    final getSchedules = ref.read(getSchedulesUsecaseProvider);
    final result = await getSchedules();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (schedules) => schedules,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSchedules());
  }

  Future<void> createSchedule({
    required String proposalId,
    required DateTime proposedDate,
    required String proposedTime,
    required int durationMinutes,
  }) async {
    final createSchedule = ref.read(createScheduleUsecaseProvider);

    final schedule = ScheduleEntity(
      proposalId: proposalId,
      proposedDate: proposedDate,
      proposedTime: proposedTime,
      durationMinutes: durationMinutes,
      accepted: false,
    );

    final result = await createSchedule(
      CreateScheduleParams(schedule: schedule),
    );

    result.fold((failure) => throw Exception(failure.message), (
      createdSchedule,
    ) {
      state = AsyncValue.data([...state.value ?? [], createdSchedule]);
    });
  }

  Future<void> acceptSchedule(String id) async {
    final acceptSchedule = ref.read(acceptScheduleUsecaseProvider);
    final result = await acceptSchedule(AcceptScheduleParams(id: id));

    result.fold((failure) => throw Exception(failure.message), (
      updatedSchedule,
    ) {
      final currentSchedules = state.value ?? [];
      state = AsyncValue.data(
        currentSchedules.map((s) => s.id == id ? updatedSchedule : s).toList(),
      );
    });
  }
}
