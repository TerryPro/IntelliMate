import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class DeleteSchedule {
  final ScheduleRepository repository;

  DeleteSchedule(this.repository);

  Future<Result<bool>> call(String id) async {
    try {
      return await repository.deleteSchedule(id);
    } catch (e) {
      return Result.failure("删除日程失败: $e");
    }
  }
} 