import 'package:intellimate/data/datasources/daily_note_datasource.dart';
import 'package:intellimate/data/models/daily_note_model.dart';
import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class DailyNoteRepositoryImpl implements DailyNoteRepository {
  final DailyNoteDataSource _dataSource;

  DailyNoteRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<DailyNoteModel>>> getAllDailyNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      final notes = await _dataSource.getAllDailyNotes(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      return Result.success(notes);
    } catch (e) {
      return Result.failure("获取所有日常点滴失败: $e");
    }
  }

  @override
  Future<Result<DailyNoteModel>> getDailyNoteById(String id) async {
    try {
      final note = await _dataSource.getDailyNoteById(id);
      if (note == null) {
        return Result.failure("找不到ID为$id的日常点滴");
      }
      return Result.success(note);
    } catch (e) {
      return Result.failure("获取日常点滴详情失败: $e");
    }
  }

  @override
  Future<Result<DailyNoteModel>> createDailyNote({
    required String content,
    required DateTime date,
    String? mood,
    String? weather,
    bool isPrivate = false,
    List<String>? images,
    List<String>? codeSnippets,
    List<String>? tags,
  }) async {
    try {
      final now = DateTime.now();
      final dailyNoteModel = DailyNoteModel(
        id: '', // 会在数据源中生成
        content: content,
        mood: mood,
        weather: weather,
        isPrivate: isPrivate,
        images: images,
        codeSnippet: codeSnippets?.isNotEmpty == true ? codeSnippets![0] : null,
        createdAt: date,
        updatedAt: now,
      );
      
      final result = await _dataSource.createDailyNote(dailyNoteModel);
      return Result.success(result);
    } catch (e) {
      return Result.failure("创建日常点滴失败: $e");
    }
  }

  @override
  Future<Result<DailyNoteModel>> updateDailyNote(DailyNote dailyNote) async {
    try {
      final dailyNoteModel = DailyNoteModel.fromEntity(dailyNote);
      final affected = await _dataSource.updateDailyNote(dailyNoteModel);
      if (affected > 0) {
        // 获取更新后的数据并返回
        final updated = await _dataSource.getDailyNoteById(dailyNote.id);
        if (updated != null) {
          return Result.success(updated);
        }
        return Result.success(dailyNoteModel);
      } else {
        return Result.failure("更新日常点滴失败: 没有记录被更新");
      }
    } catch (e) {
      return Result.failure("更新日常点滴失败: $e");
    }
  }

  @override
  Future<Result<bool>> deleteDailyNote(String id) async {
    try {
      final result = await _dataSource.deleteDailyNote(id);
      if (result > 0) {
        return Result.success(true);
      } else {
        return Result.failure("删除日常点滴失败: 没有记录被删除");
      }
    } catch (e) {
      return Result.failure("删除日常点滴失败: $e");
    }
  }

  @override
  Future<Result<List<DailyNoteModel>>> searchDailyNotes(String query) async {
    try {
      final notes = await _dataSource.searchDailyNotes(query);
      return Result.success(notes);
    } catch (e) {
      return Result.failure("搜索日常点滴失败: $e");
    }
  }

  @override
  Future<Result<List<DailyNoteModel>>> getPrivateDailyNotes() async {
    try {
      final notes = await _dataSource.getPrivateDailyNotes();
      return Result.success(notes);
    } catch (e) {
      return Result.failure("获取私密日常点滴失败: $e");
    }
  }

  @override
  Future<Result<List<DailyNoteModel>>> getDailyNotesWithCodeSnippets() async {
    try {
      final notes = await _dataSource.getDailyNotesWithCodeSnippets();
      return Result.success(notes);
    } catch (e) {
      return Result.failure("获取包含代码片段的日常点滴失败: $e");
    }
  }

  @override
  Future<Result<List<DailyNoteModel>>> getDailyNotesByCondition({
    String? mood,
    String? weather,
    bool? isPrivate,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      final notes = await _dataSource.getDailyNotesByCondition(
        mood: mood,
        weather: weather,
        isPrivate: isPrivate,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      return Result.success(notes);
    } catch (e) {
      return Result.failure("根据条件获取日常点滴失败: $e");
    }
  }
} 