import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class GetUpcomingSchedules {
  final ScheduleRepository repository;

  GetUpcomingSchedules(this.repository);

  Future<List<Schedule>> call({
    int limit = 10,
    String? category,
  }) async {
    return await repository.getUpcomingSchedules(
      limit: limit,
      category: category,
    );
  }
} 