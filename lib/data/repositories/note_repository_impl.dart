import 'package:intellimate/data/datasources/note_datasource.dart';
import 'package:intellimate/data/models/note_model.dart';
import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteDataSource dataSource;

  NoteRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<NoteModel>>> getAllNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      final notes = await dataSource.getAllNotes(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      return Result.success(notes);
    } catch (e) {
      return Result.failure("获取所有笔记失败: $e");
    }
  }

  @override
  Future<Result<NoteModel>> getNoteById(String id) async {
    try {
      final note = await dataSource.getNoteById(id);
      if (note == null) {
        return Result.failure("找不到ID为$id的笔记");
      }
      return Result.success(note);
    } catch (e) {
      return Result.failure("获取笔记详情失败: $e");
    }
  }

  @override
  Future<Result<NoteModel>> createNote({
    required String title,
    required String content,
    List<String>? tags,
    String? category,
    bool isFavorite = false,
  }) async {
    try {
      final now = DateTime.now();
      final noteModel = NoteModel(
        id: '', // 会在数据源中生成
        title: title,
        content: content,
        tags: tags,
        category: category,
        isFavorite: isFavorite,
        createdAt: now,
        updatedAt: now,
      );
      
      final result = await dataSource.createNote(noteModel);
      return Result.success(result);
    } catch (e) {
      return Result.failure("创建笔记失败: $e");
    }
  }

  @override
  Future<Result<NoteModel>> updateNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final affected = await dataSource.updateNote(noteModel);
      if (affected > 0) {
        // 获取更新后的数据并返回
        final updated = await dataSource.getNoteById(note.id);
        if (updated != null) {
          return Result.success(updated);
        }
        return Result.success(noteModel);
      } else {
        return Result.failure("更新笔记失败: 没有记录被更新");
      }
    } catch (e) {
      return Result.failure("更新笔记失败: $e");
    }
  }

  @override
  Future<Result<bool>> deleteNote(String id) async {
    try {
      final result = await dataSource.deleteNote(id);
      if (result > 0) {
        return Result.success(true);
      } else {
        return Result.failure("删除笔记失败: 没有记录被删除");
      }
    } catch (e) {
      return Result.failure("删除笔记失败: $e");
    }
  }

  @override
  Future<Result<List<NoteModel>>> searchNotes(String query) async {
    try {
      final notes = await dataSource.searchNotes(query);
      return Result.success(notes);
    } catch (e) {
      return Result.failure("搜索笔记失败: $e");
    }
  }

  @override
  Future<Result<List<NoteModel>>> getFavoriteNotes() async {
    try {
      final notes = await dataSource.getFavoriteNotes();
      return Result.success(notes);
    } catch (e) {
      return Result.failure("获取收藏笔记失败: $e");
    }
  }

  @override
  Future<Result<List<NoteModel>>> getNotesByCategory(String category) async {
    try {
      final notes = await dataSource.getNotesByCategory(category);
      return Result.success(notes);
    } catch (e) {
      return Result.failure("获取分类笔记失败: $e");
    }
  }

  @override
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
  }) async {
    try {
      final notes = await dataSource.getNotesByCondition(
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
      return Result.success(notes);
    } catch (e) {
      return Result.failure("根据条件获取笔记失败: $e");
    }
  }
} 