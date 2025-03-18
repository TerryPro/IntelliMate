import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/daily_note_model.dart';

class GetPrivateDailyNotes {
  final DailyNoteRepository repository;

  GetPrivateDailyNotes(this.repository);

  Future<Result<List<DailyNoteModel>>> call() async {
    try {
      return await repository.getPrivateDailyNotes();
    } catch (e) {
      return Result.failure("获取私密日常点滴失败: $e");
    }
  }
} 