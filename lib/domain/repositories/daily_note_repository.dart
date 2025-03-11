import 'package:intellimate/domain/entities/daily_note.dart';

abstract class DailyNoteRepository {
  // 获取所有日常点滴
  Future<List<DailyNote>> getAllDailyNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
  
  // 根据ID获取日常点滴
  Future<DailyNote?> getDailyNoteById(String id);
  
  // 创建日常点滴
  Future<DailyNote> createDailyNote(DailyNote dailyNote);
  
  // 更新日常点滴
  Future<bool> updateDailyNote(DailyNote dailyNote);
  
  // 删除日常点滴
  Future<bool> deleteDailyNote(String id);
  
  // 搜索日常点滴
  Future<List<DailyNote>> searchDailyNotes(String query);
  
  // 获取私密日常点滴
  Future<List<DailyNote>> getPrivateDailyNotes();
  
  // 获取包含代码片段的日常点滴
  Future<List<DailyNote>> getDailyNotesWithCodeSnippets();
  
  // 根据条件获取日常点滴
  Future<List<DailyNote>> getDailyNotesByCondition({
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