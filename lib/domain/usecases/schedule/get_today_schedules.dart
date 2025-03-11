import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class GetTodaySchedules {
  final ScheduleRepository repository;

  GetTodaySchedules(this.repository);

  Future<List<Schedule>> call({
    bool includeAllDay = true,
    String? category,
  }) async {
    return await repository.getTodaySchedules(
      includeAllDay: includeAllDay,
      category: category,
    );
  }
} 