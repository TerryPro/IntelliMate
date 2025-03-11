import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class CreateSchedule {
  final ScheduleRepository repository;

  CreateSchedule(this.repository);

  Future<Schedule> call({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    required bool isAllDay,
    String? category,
    required bool isRepeated,
    String? repeatType,
    List<String>? participants,
    String? reminder,
  }) async {
    return await repository.createSchedule(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      isAllDay: isAllDay,
      category: category,
      isRepeated: isRepeated,
      repeatType: repeatType,
      participants: participants,
      reminder: reminder,
    );
  }
} 