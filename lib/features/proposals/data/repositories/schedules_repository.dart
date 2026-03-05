import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/core/services/connectivity/network_info.dart';
import 'package:skillswap/features/proposals/data/datasources/remote/schedules_remote_datasource.dart';
import 'package:skillswap/features/proposals/data/models/schedule_model.dart';
import 'package:skillswap/features/proposals/domain/repositories/schedules_repository_interface.dart';

final schedulesRepositoryProvider = Provider<ISchedulesRepository>((ref) {
  final schedulesRemoteDatasource = ref.read(schedulesRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return SchedulesRepository(
    schedulesRemoteDatasource: schedulesRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class SchedulesRepository implements ISchedulesRepository {
  final SchedulesRemoteDatasource _schedulesRemoteDatasource;
  final NetworkInfo _networkInfo;

  SchedulesRepository({
    required SchedulesRemoteDatasource schedulesRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _schedulesRemoteDatasource = schedulesRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<ScheduleModel>>> getSchedules() async {
    if (await _networkInfo.isConnected) {
      try {
        final schedules = await _schedulesRemoteDatasource.getSchedules();
        return Right(schedules);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch schedules',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ScheduleModel>> getScheduleById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final schedule = await _schedulesRemoteDatasource.getScheduleById(id);
        return Right(schedule);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch schedule',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ScheduleModel>> createSchedule(
    ScheduleModel schedule,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final createdSchedule = await _schedulesRemoteDatasource.createSchedule(
          schedule,
        );
        return Right(createdSchedule);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to create schedule',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ScheduleModel>> acceptSchedule(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final schedule = await _schedulesRemoteDatasource.acceptSchedule(id);
        return Right(schedule);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to accept schedule',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
