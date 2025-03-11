import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class UpdateSchedule {
  final ScheduleRepository repository;

  UpdateSchedule(this.repository);

  Future<bool> call(Schedule schedule) async {
    return await repository.updateSchedule(schedule);
  }
} 