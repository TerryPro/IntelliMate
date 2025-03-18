import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class GetSchedulesByDateRange {
  final ScheduleRepository repository;

  GetSchedulesByDateRange(this.repository);

  Future<Result<List<ScheduleModel>>> call(
    DateTime startDate,
    DateTime endDate, {
    bool includeAllDay = true,
    String? category,
    bool? isRepeated,
  }) async {
    try {
      return await repository.getSchedulesByDateRange(
        startDate,
        endDate,
        includeAllDay: includeAllDay,
        category: category,
        isRepeated: isRepeated,
      );
    } catch (e) {
      return Result.failure("获取日期范围内的日程失败: $e");
    }
  }
} 