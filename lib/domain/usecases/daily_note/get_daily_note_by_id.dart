import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class GetDailyNoteById {
  final DailyNoteRepository repository;

  GetDailyNoteById(this.repository);

  Future<DailyNote?> execute(String id) async {
    return await repository.getDailyNoteById(id);
  }
} 