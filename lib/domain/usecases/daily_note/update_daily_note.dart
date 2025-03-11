import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class UpdateDailyNote {
  final DailyNoteRepository repository;

  UpdateDailyNote(this.repository);

  Future<bool> execute(DailyNote dailyNote) async {
    return await repository.updateDailyNote(dailyNote);
  }
} 