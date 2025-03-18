import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/note_model.dart';

class GetNoteById {
  final NoteRepository repository;

  GetNoteById(this.repository);

  Future<Result<NoteModel>> call(String id) async {
    try {
      return await repository.getNoteById(id);
    } catch (e) {
      return Result.failure("获取笔记详情失败: $e");
    }
  }
} 