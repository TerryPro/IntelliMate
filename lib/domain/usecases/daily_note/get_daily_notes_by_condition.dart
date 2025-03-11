import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class GetDailyNotesByCondition {
  final DailyNoteRepository repository;

  GetDailyNotesByCondition(this.repository);

  Future<List<DailyNote>> execute({
    String? mood,
    String? weather,
    bool? isPrivate,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await repository.getDailyNotesByCondition(
      mood: mood,
      weather: weather,
      isPrivate: isPrivate,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
} 