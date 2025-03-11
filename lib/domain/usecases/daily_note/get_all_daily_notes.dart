import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class GetAllDailyNotes {
  final DailyNoteRepository repository;

  GetAllDailyNotes(this.repository);

  Future<List<DailyNote>> execute({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await repository.getAllDailyNotes(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
} 