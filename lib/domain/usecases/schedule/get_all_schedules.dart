import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class GetAllSchedules {
  final ScheduleRepository repository;

  GetAllSchedules(this.repository);

  Future<Result<List<ScheduleModel>>> call({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      return await repository.getAllSchedules(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
    } catch (e) {
      return Result.failure("获取所有日程失败: $e");
    }
  }
} 