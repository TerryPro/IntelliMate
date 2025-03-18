import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/daily_note_model.dart';

abstract class DailyNoteRepository {
  // 获取所有日常点滴
  Future<Result<List<DailyNoteModel>>> getAllDailyNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
  
  // 根据ID获取日常点滴
  Future<Result<DailyNoteModel>> getDailyNoteById(String id);
  
  // 创建日常点滴
  Future<Result<DailyNoteModel>> createDailyNote({
    required String content,
    required DateTime date,
    String? mood,
    String? weather,
    bool isPrivate = false,
    List<String>? images,
    List<String>? codeSnippets,
    List<String>? tags,
  });
  
  // 更新日常点滴
  Future<Result<DailyNoteModel>> updateDailyNote(DailyNote dailyNote);
  
  // 删除日常点滴
  Future<Result<bool>> deleteDailyNote(String id);
  
  // 搜索日常点滴
  Future<Result<List<DailyNoteModel>>> searchDailyNotes(String query);
  
  // 获取私密日常点滴
  Future<Result<List<DailyNoteModel>>> getPrivateDailyNotes();
  
  // 获取包含代码片段的日常点滴
  Future<Result<List<DailyNoteModel>>> getDailyNotesWithCodeSnippets();
  
  // 根据条件获取日常点滴
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
  });
} 