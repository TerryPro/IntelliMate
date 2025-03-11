import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class GetSchedulesByDate {
  final ScheduleRepository repository;

  GetSchedulesByDate(this.repository);

  Future<List<Schedule>> call(
    DateTime date, {
    bool includeAllDay = true,
    String? category,
  }) async {
    return await repository.getSchedulesByDate(
      date,
      includeAllDay: includeAllDay,
      category: category,
    );
  }
} 