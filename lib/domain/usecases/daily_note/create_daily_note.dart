import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class CreateDailyNote {
  final DailyNoteRepository repository;

  CreateDailyNote(this.repository);

  Future<DailyNote> execute(DailyNote dailyNote) async {
    return await repository.createDailyNote(dailyNote);
  }
} 