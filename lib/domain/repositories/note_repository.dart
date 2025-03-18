import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/note_model.dart';

abstract class NoteRepository {
  // 获取所有笔记
  Future<Result<List<NoteModel>>> getAllNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
  
  // 根据ID获取笔记
  Future<Result<NoteModel>> getNoteById(String id);
  
  // 创建笔记
  Future<Result<NoteModel>> createNote({
    required String title,
    required String content,
    List<String>? tags,
    String? category,
    bool isFavorite = false,
  });
  
  // 更新笔记
  Future<Result<NoteModel>> updateNote(Note note);
  
  // 删除笔记
  Future<Result<bool>> deleteNote(String id);
  
  // 搜索笔记
  Future<Result<List<NoteModel>>> searchNotes(String query);
  
  // 获取收藏的笔记
  Future<Result<List<NoteModel>>> getFavoriteNotes();
  
  // 根据分类获取笔记
  Future<Result<List<NoteModel>>> getNotesByCategory(String category);
  
  // 根据条件获取笔记
  Future<Result<List<NoteModel>>> getNotesByCondition({
    String? category,
    bool? isFavorite,
    List<String>? tags,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
} 