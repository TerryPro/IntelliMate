import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/daily_note_model.dart';

class UpdateDailyNote {
  final DailyNoteRepository repository;

  UpdateDailyNote(this.repository);

  Future<Result<DailyNoteModel>> call(DailyNote dailyNote) async {
    try {
      return await repository.updateDailyNote(dailyNote);
    } catch (e) {
      return Result.failure("更新日常点滴失败: $e");
    }
  }
} 