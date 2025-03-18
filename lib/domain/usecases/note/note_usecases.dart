import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/note_model.dart';

/// 获取所有笔记用例
class GetAllNotesUseCase {
  final NoteRepository _repository;

  GetAllNotesUseCase(this._repository);

  Future<Result<List<NoteModel>>> call({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      return await _repository.getAllNotes(
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

/// 根据ID获取笔记用例
class GetNoteByIdUseCase {
  final NoteRepository _repository;

  GetNoteByIdUseCase(this._repository);

  Future<Result<NoteModel>> call(String id) async {
    try {
      return await _repository.getNoteById(id);
    } catch (e) {
      return Result.failure("获取笔记详情失败: $e");
    }
  }
}

/// 创建笔记用例
class CreateNoteUseCase {
  final NoteRepository _repository;

  CreateNoteUseCase(this._repository);

  Future<Result<NoteModel>> call({
    required String title,
    required String content,
    List<String>? tags,
    String? category,
    bool isFavorite = false,
  }) async {
    try {
      return await _repository.createNote(
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

/// 更新笔记用例
class UpdateNoteUseCase {
  final NoteRepository _repository;

  UpdateNoteUseCase(this._repository);

  Future<Result<NoteModel>> call(Note note) async {
    try {
      return await _repository.updateNote(note);
    } catch (e) {
      return Result.failure("更新笔记失败: $e");
    }
  }
}

/// 删除笔记用例
class DeleteNoteUseCase {
  final NoteRepository _repository;

  DeleteNoteUseCase(this._repository);

  Future<Result<bool>> call(String id) async {
    try {
      return await _repository.deleteNote(id);
    } catch (e) {
      return Result.failure("删除笔记失败: $e");
    }
  }
}

/// 搜索笔记用例
class SearchNotesUseCase {
  final NoteRepository _repository;

  SearchNotesUseCase(this._repository);

  Future<Result<List<NoteModel>>> call(String query) async {
    try {
      return await _repository.searchNotes(query);
    } catch (e) {
      return Result.failure("搜索笔记失败: $e");
    }
  }
}

/// 获取收藏笔记用例
class GetFavoriteNotesUseCase {
  final NoteRepository _repository;

  GetFavoriteNotesUseCase(this._repository);

  Future<Result<List<NoteModel>>> call() async {
    try {
      return await _repository.getFavoriteNotes();
    } catch (e) {
      return Result.failure("获取收藏笔记失败: $e");
    }
  }
}

/// 根据分类获取笔记用例
class GetNotesByCategoryUseCase {
  final NoteRepository _repository;

  GetNotesByCategoryUseCase(this._repository);

  Future<Result<List<NoteModel>>> call(String category) async {
    try {
      return await _repository.getNotesByCategory(category);
    } catch (e) {
      return Result.failure("获取分类笔记失败: $e");
    }
  }
}

/// 根据条件获取笔记用例
class GetNotesByConditionUseCase {
  final NoteRepository _repository;

  GetNotesByConditionUseCase(this._repository);

  Future<Result<List<NoteModel>>> call({
    String? category,
    bool? isFavorite,
    List<String>? tags,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      return await _repository.getNotesByCondition(
        category: category,
        isFavorite: isFavorite,
        tags: tags,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
    } catch (e) {
      return Result.failure("根据条件获取笔记失败: $e");
    }
  }
} 