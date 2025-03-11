import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';

/// 获取所有笔记用例
class GetAllNotesUseCase {
  final NoteRepository _repository;

  GetAllNotesUseCase(this._repository);

  Future<List<Note>> call({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await _repository.getAllNotes(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
}

/// 根据ID获取笔记用例
class GetNoteByIdUseCase {
  final NoteRepository _repository;

  GetNoteByIdUseCase(this._repository);

  Future<Note?> call(String id) async {
    return await _repository.getNoteById(id);
  }
}

/// 创建笔记用例
class CreateNoteUseCase {
  final NoteRepository _repository;

  CreateNoteUseCase(this._repository);

  Future<Note> call(Note note) async {
    return await _repository.createNote(note);
  }
}

/// 更新笔记用例
class UpdateNoteUseCase {
  final NoteRepository _repository;

  UpdateNoteUseCase(this._repository);

  Future<bool> call(Note note) async {
    return await _repository.updateNote(note);
  }
}

/// 删除笔记用例
class DeleteNoteUseCase {
  final NoteRepository _repository;

  DeleteNoteUseCase(this._repository);

  Future<bool> call(String id) async {
    return await _repository.deleteNote(id);
  }
}

/// 搜索笔记用例
class SearchNotesUseCase {
  final NoteRepository _repository;

  SearchNotesUseCase(this._repository);

  Future<List<Note>> call(String query) async {
    return await _repository.searchNotes(query);
  }
}

/// 获取收藏笔记用例
class GetFavoriteNotesUseCase {
  final NoteRepository _repository;

  GetFavoriteNotesUseCase(this._repository);

  Future<List<Note>> call() async {
    return await _repository.getFavoriteNotes();
  }
}

/// 根据分类获取笔记用例
class GetNotesByCategoryUseCase {
  final NoteRepository _repository;

  GetNotesByCategoryUseCase(this._repository);

  Future<List<Note>> call(String category) async {
    return await _repository.getNotesByCategory(category);
  }
}

/// 根据条件获取笔记用例
class GetNotesByConditionUseCase {
  final NoteRepository _repository;

  GetNotesByConditionUseCase(this._repository);

  Future<List<Note>> call({
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
  }
} 