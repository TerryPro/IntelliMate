import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/note_model.dart';

class SearchNotes {
  final NoteRepository repository;

  SearchNotes(this.repository);

  Future<Result<List<NoteModel>>> call(String query) async {
    try {
      return await repository.searchNotes(query);
    } catch (e) {
      return Result.failure("搜索笔记失败: $e");
    }
  }
} 