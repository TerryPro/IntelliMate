import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/daily_note_model.dart';

class SearchDailyNotes {
  final DailyNoteRepository repository;

  SearchDailyNotes(this.repository);

  Future<Result<List<DailyNoteModel>>> call(String query) async {
    try {
      return await repository.searchDailyNotes(query);
    } catch (e) {
      return Result.failure("搜索日常点滴失败: $e");
    }
  }
} 