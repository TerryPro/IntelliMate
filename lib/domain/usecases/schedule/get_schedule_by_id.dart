import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class GetScheduleById {
  final ScheduleRepository repository;

  GetScheduleById(this.repository);

  Future<Schedule?> call(String id) async {
    return await repository.getScheduleById(id);
  }
} 