import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class SearchDailyNotes {
  final DailyNoteRepository repository;

  SearchDailyNotes(this.repository);

  Future<List<DailyNote>> execute(String query) async {
    return await repository.searchDailyNotes(query);
  }
} 