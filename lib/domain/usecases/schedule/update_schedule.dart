import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class UpdateSchedule {
  final ScheduleRepository repository;

  UpdateSchedule(this.repository);

  Future<Result<ScheduleModel>> call(Schedule schedule) async {
    try {
      return await repository.updateSchedule(schedule);
    } catch (e) {
      return Result.failure("更新日程失败: $e");
    }
  }
} 