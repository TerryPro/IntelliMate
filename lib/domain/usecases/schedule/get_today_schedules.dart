import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class GetTodaySchedules {
  final ScheduleRepository repository;

  GetTodaySchedules(this.repository);

  Future<Result<List<ScheduleModel>>> call({
    bool includeAllDay = true,
    String? category,
  }) async {
    try {
      return await repository.getTodaySchedules(
        includeAllDay: includeAllDay,
        category: category,
      );
    } catch (e) {
      return Result.failure("获取今日日程失败: $e");
    }
  }
} 