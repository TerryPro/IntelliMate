import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class GetSchedulesByDate {
  final ScheduleRepository repository;

  GetSchedulesByDate(this.repository);

  Future<Result<List<ScheduleModel>>> call(
    DateTime date, {
    bool includeAllDay = true,
    String? category,
  }) async {
    try {
      return await repository.getSchedulesByDate(
        date,
        includeAllDay: includeAllDay,
        category: category,
      );
    } catch (e) {
      return Result.failure("获取指定日期的日程失败: $e");
    }
  }
} 