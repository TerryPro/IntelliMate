import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class GetSchedulesByCategory {
  final ScheduleRepository repository;

  GetSchedulesByCategory(this.repository);

  Future<List<Schedule>> call(String category) async {
    return await repository.getSchedulesByCategory(category);
  }
} 