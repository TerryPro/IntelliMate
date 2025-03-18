import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/note_model.dart';

class GetAllNotes {
  final NoteRepository repository;

  GetAllNotes(this.repository);

  Future<Result<List<NoteModel>>> call({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      return await repository.getAllNotes(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
    } catch (e) {
      return Result.failure("获取所有笔记失败: $e");
    }
  }
} 