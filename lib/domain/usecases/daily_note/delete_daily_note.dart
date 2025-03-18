import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class DeleteDailyNote {
  final DailyNoteRepository repository;

  DeleteDailyNote(this.repository);

  Future<Result<bool>> call(String id) async {
    try {
      return await repository.deleteDailyNote(id);
    } catch (e) {
      return Result.failure("删除日常点滴失败: $e");
    }
  }
} 