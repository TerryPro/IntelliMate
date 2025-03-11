import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class GetPrivateDailyNotes {
  final DailyNoteRepository repository;

  GetPrivateDailyNotes(this.repository);

  Future<List<DailyNote>> execute() async {
    return await repository.getPrivateDailyNotes();
  }
} 