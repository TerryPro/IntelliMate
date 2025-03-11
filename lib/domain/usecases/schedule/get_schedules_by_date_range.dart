import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class GetSchedulesByDateRange {
  final ScheduleRepository repository;

  GetSchedulesByDateRange(this.repository);

  Future<List<Schedule>> call(
    DateTime startDate,
    DateTime endDate, {
    bool includeAllDay = true,
    String? category,
    bool? isRepeated,
  }) async {
    return await repository.getSchedulesByDateRange(
      startDate,
      endDate,
      includeAllDay: includeAllDay,
      category: category,
      isRepeated: isRepeated,
    );
  }
} 