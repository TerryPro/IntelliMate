import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/daily_note_model.dart';

class GetDailyNoteById {
  final DailyNoteRepository repository;

  GetDailyNoteById(this.repository);

  Future<Result<DailyNoteModel>> call(String id) async {
    try {
      return await repository.getDailyNoteById(id);
    } catch (e) {
      return Result.failure("获取日常点滴详情失败: $e");
    }
  }
} 