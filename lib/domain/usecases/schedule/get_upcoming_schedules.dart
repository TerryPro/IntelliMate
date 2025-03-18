import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class GetUpcomingSchedules {
  final ScheduleRepository repository;

  GetUpcomingSchedules(this.repository);

  Future<Result<List<ScheduleModel>>> call({
    int limit = 10,
    String? category,
  }) async {
    try {
      return await repository.getUpcomingSchedules(
        limit: limit,
        category: category,
      );
    } catch (e) {
      return Result.failure("获取未来日程失败: $e");
    }
  }
} 