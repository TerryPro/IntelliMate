import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/note_model.dart';

class UpdateNote {
  final NoteRepository repository;

  UpdateNote(this.repository);

  Future<Result<NoteModel>> call(Note note) async {
    try {
      return await repository.updateNote(note);
    } catch (e) {
      return Result.failure("更新笔记失败: $e");
    }
  }
} 