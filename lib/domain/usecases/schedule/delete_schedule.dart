import 'package:intellimate/domain/repositories/schedule_repository.dart';

class DeleteSchedule {
  final ScheduleRepository repository;

  DeleteSchedule(this.repository);

  Future<bool> call(String id) async {
    return await repository.deleteSchedule(id);
  }
} 