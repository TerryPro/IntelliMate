import 'package:intellimate/domain/entities/note.dart';

abstract class NoteRepository {
  // 获取所有笔记
  Future<List<Note>> getAllNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
  
  // 根据ID获取笔记
  Future<Note?> getNoteById(String id);
  
  // 创建笔记
  Future<Note> createNote(Note note);
  
  // 更新笔记
  Future<bool> updateNote(Note note);
  
  // 删除笔记
  Future<bool> deleteNote(String id);
  
  // 搜索笔记
  Future<List<Note>> searchNotes(String query);
  
  // 获取收藏的笔记
  Future<List<Note>> getFavoriteNotes();
  
  // 根据分类获取笔记
  Future<List<Note>> getNotesByCategory(String category);
  
  // 根据条件获取笔记
  Future<List<Note>> getNotesByCondition({
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