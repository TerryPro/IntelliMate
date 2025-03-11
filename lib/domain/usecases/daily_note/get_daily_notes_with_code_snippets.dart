import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class GetDailyNotesWithCodeSnippets {
  final DailyNoteRepository repository;

  GetDailyNotesWithCodeSnippets(this.repository);

  Future<List<DailyNote>> execute() async {
    return await repository.getDailyNotesWithCodeSnippets();
  }
} 