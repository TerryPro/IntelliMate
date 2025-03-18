import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class DeleteNote {
  final NoteRepository repository;

  DeleteNote(this.repository);

  Future<Result<bool>> call(String id) async {
    try {
      return await repository.deleteNote(id);
    } catch (e) {
      return Result.failure("删除笔记失败: $e");
    }
  }
} 