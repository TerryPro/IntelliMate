import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class DeleteDailyNote {
  final DailyNoteRepository repository;

  DeleteDailyNote(this.repository);

  Future<bool> execute(String id) async {
    return await repository.deleteDailyNote(id);
  }
} 