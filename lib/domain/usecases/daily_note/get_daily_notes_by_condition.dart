import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/daily_note_model.dart';

class GetDailyNotesByCondition {
  final DailyNoteRepository repository;

  GetDailyNotesByCondition(this.repository);

  Future<Result<List<DailyNoteModel>>> call({
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
    try {
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
    } catch (e) {
      return Result.failure("根据条件获取日常点滴失败: $e");
    }
  }
} 