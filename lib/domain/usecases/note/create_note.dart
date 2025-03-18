import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/note_model.dart';

class CreateNote {
  final NoteRepository repository;

  CreateNote(this.repository);

  Future<Result<NoteModel>> call({
    required String title,
    required String content,
    List<String>? tags,
    String? category,
    bool isFavorite = false,
  }) async {
    try {
      return await repository.createNote(
        title: title,
        content: content,
        tags: tags,
        category: category,
        isFavorite: isFavorite,
      );
    } catch (e) {
      return Result.failure("创建笔记失败: $e");
    }
  }
} 