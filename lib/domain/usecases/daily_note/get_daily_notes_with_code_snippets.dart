import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/daily_note_model.dart';

class GetDailyNotesWithCodeSnippets {
  final DailyNoteRepository repository;

  GetDailyNotesWithCodeSnippets(this.repository);

  Future<Result<List<DailyNoteModel>>> call() async {
    try {
      return await repository.getDailyNotesWithCodeSnippets();
    } catch (e) {
      return Result.failure("获取包含代码片段的日常点滴失败: $e");
    }
  }
} 