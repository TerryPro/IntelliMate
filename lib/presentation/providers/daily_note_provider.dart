import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/usecases/daily_note/create_daily_note.dart';
import 'package:intellimate/domain/usecases/daily_note/delete_daily_note.dart';
import 'package:intellimate/domain/usecases/daily_note/get_all_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_note_by_id.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_notes_by_condition.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_notes_with_code_snippets.dart';
import 'package:intellimate/domain/usecases/daily_note/get_private_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/search_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/update_daily_note.dart';

class DailyNoteProvider extends ChangeNotifier {
  final CreateDailyNote _createDailyNoteUseCase;
  final DeleteDailyNote _deleteDailyNoteUseCase;
  final GetAllDailyNotes _getAllDailyNotesUseCase;
  final GetDailyNoteById _getDailyNoteByIdUseCase;
  final GetDailyNotesByCondition _getDailyNotesByConditionUseCase;
  final GetDailyNotesWithCodeSnippets _getDailyNotesWithCodeSnippetsUseCase;
  final GetPrivateDailyNotes _getPrivateDailyNotesUseCase;
  final SearchDailyNotes _searchDailyNotesUseCase;
  final UpdateDailyNote _updateDailyNoteUseCase;

  DailyNoteProvider({
    required CreateDailyNote createDailyNoteUseCase,
    required DeleteDailyNote deleteDailyNoteUseCase,
    required GetAllDailyNotes getAllDailyNotesUseCase,
    required GetDailyNoteById getDailyNoteByIdUseCase,
    required GetDailyNotesByCondition getDailyNotesByConditionUseCase,
    required GetDailyNotesWithCodeSnippets getDailyNotesWithCodeSnippetsUseCase,
    required GetPrivateDailyNotes getPrivateDailyNotesUseCase,
    required SearchDailyNotes searchDailyNotesUseCase,
    required UpdateDailyNote updateDailyNoteUseCase,
  })  : _createDailyNoteUseCase = createDailyNoteUseCase,
        _deleteDailyNoteUseCase = deleteDailyNoteUseCase,
        _getAllDailyNotesUseCase = getAllDailyNotesUseCase,
        _getDailyNoteByIdUseCase = getDailyNoteByIdUseCase,
        _getDailyNotesByConditionUseCase = getDailyNotesByConditionUseCase,
        _getDailyNotesWithCodeSnippetsUseCase =
            getDailyNotesWithCodeSnippetsUseCase,
        _getPrivateDailyNotesUseCase = getPrivateDailyNotesUseCase,
        _searchDailyNotesUseCase = searchDailyNotesUseCase,
        _updateDailyNoteUseCase = updateDailyNoteUseCase;

  // 状态变量
  List<DailyNote> _dailyNotes = [];
  DailyNote? _selectedDailyNote;
  bool _isLoading = false;
  String? _error;

  // Getter
  List<DailyNote> get dailyNotes => _dailyNotes;
  DailyNote? get selectedDailyNote => _selectedDailyNote;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 获取所有日常点滴
  Future<void> getAllDailyNotes() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _getAllDailyNotesUseCase.call();
      result.fold(
        onSuccess: (notes) => _dailyNotes = notes,
        onFailure: (error) => _setError(error)
      );
    } catch (e) {
      _setError('获取日常点滴失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 根据ID获取日常点滴
  Future<DailyNote?> getDailyNoteById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _getDailyNoteByIdUseCase.call(id);
      DailyNote? note;
      result.fold(
        onSuccess: (data) {
          _selectedDailyNote = data;
          note = data;
        },
        onFailure: (error) {
          _setError(error);
          note = null;
        }
      );
      return note;
    } catch (e) {
      _setError('获取日常点滴失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 创建日常点滴
  Future<DailyNote?> createDailyNote({
    required String content,
    String? author,
    List<String>? images,
    String? location,
    String? mood,
    String? weather,
    bool isPrivate = false,
    String? codeSnippet,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // 创建临时ID，实际ID将由数据库生成
      final now = DateTime.now();

      final result = await _createDailyNoteUseCase.call(
        content: content,
        date: now,
        mood: mood,
        weather: weather,
        isPrivate: isPrivate,
        images: images,
        codeSnippets: codeSnippet != null ? [codeSnippet] : null,
      );
      
      DailyNote? createdDailyNote;
      
      result.fold(
        onSuccess: (data) {
          createdDailyNote = data;
          _dailyNotes.insert(0, data);
          notifyListeners();
        },
        onFailure: (error) {
          _setError(error);
          createdDailyNote = null;
        }
      );
      
      return createdDailyNote;
    } catch (e) {
      _setError('创建日常点滴失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 更新日常点滴
  Future<bool> updateDailyNote(DailyNote dailyNote) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _updateDailyNoteUseCase.call(dailyNote);
      bool success = false;
      
      result.fold(
        onSuccess: (data) {
          // 修改为直接使用data返回的DailyNote模型
          success = true;
          final index = _dailyNotes.indexWhere((note) => note.id == dailyNote.id);
          if (index != -1) {
            _dailyNotes[index] = dailyNote;
            notifyListeners();
          }
        },
        onFailure: (error) {
          _setError(error);
          success = false;
        }
      );
      
      return success;
    } catch (e) {
      _setError('更新日常点滴失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 删除日常点滴
  Future<bool> deleteDailyNote(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _deleteDailyNoteUseCase.call(id);
      bool success = false;
      
      result.fold(
        onSuccess: (data) {
          // 我们假设如果返回了数据，则操作成功
          success = true;
          _dailyNotes.removeWhere((note) => note.id == id);
          notifyListeners();
        },
        onFailure: (error) {
          _setError(error);
          success = false;
        }
      );
      
      return success;
    } catch (e) {
      _setError('删除日常点滴失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 搜索日常点滴
  Future<List<DailyNote>> searchDailyNotes(String query) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _searchDailyNotesUseCase.call(query);
      List<DailyNote> notes = [];
      
      result.fold(
        onSuccess: (data) {
          notes = data;
        },
        onFailure: (error) {
          _setError(error);
          notes = [];
        }
      );
      
      return notes;
    } catch (e) {
      _setError('搜索日常点滴失败: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // 获取私密日常点滴
  Future<List<DailyNote>> getPrivateDailyNotes() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _getPrivateDailyNotesUseCase.call();
      List<DailyNote> notes = [];
      
      result.fold(
        onSuccess: (data) {
          notes = data;
        },
        onFailure: (error) {
          _setError(error);
          notes = [];
        }
      );
      
      return notes;
    } catch (e) {
      _setError('获取私密日常点滴失败: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // 获取包含代码片段的日常点滴
  Future<List<DailyNote>> getDailyNotesWithCodeSnippets() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _getDailyNotesWithCodeSnippetsUseCase.call();
      List<DailyNote> notes = [];
      
      result.fold(
        onSuccess: (data) {
          notes = data;
        },
        onFailure: (error) {
          _setError(error);
          notes = [];
        }
      );
      
      return notes;
    } catch (e) {
      _setError('获取包含代码片段的日常点滴失败: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

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
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _getDailyNotesByConditionUseCase.call(
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
      
      List<DailyNote> notes = [];
      result.fold(
        onSuccess: (data) {
          notes = data;
        },
        onFailure: (error) {
          _setError(error);
          notes = [];
        }
      );
      
      return notes;
    } catch (e) {
      _setError('根据条件获取日常点滴失败: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // 获取今天的日常点滴
  Future<List<DailyNote>> getTodayDailyNotes() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getDailyNotesByCondition(
      fromDate: startOfDay,
      toDate: endOfDay,
    );
  }

  // 获取昨天的日常点滴
  Future<List<DailyNote>> getYesterdayDailyNotes() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfDay =
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

    return getDailyNotesByCondition(
      fromDate: startOfDay,
      toDate: endOfDay,
    );
  }

  // 获取前天的日常点滴
  Future<List<DailyNote>> getDayBeforeYesterdayDailyNotes() async {
    final now = DateTime.now();
    final dayBeforeYesterday = now.subtract(const Duration(days: 2));
    final startOfDay = DateTime(dayBeforeYesterday.year,
        dayBeforeYesterday.month, dayBeforeYesterday.day);
    final endOfDay = DateTime(dayBeforeYesterday.year, dayBeforeYesterday.month,
        dayBeforeYesterday.day, 23, 59, 59);

    return getDailyNotesByCondition(
      fromDate: startOfDay,
      toDate: endOfDay,
    );
  }

  // 获取本周的日常点滴
  Future<List<DailyNote>> getThisWeekDailyNotes() async {
    final now = DateTime.now();
    // 计算本周的第一天（周一）
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek =
        DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);

    return getDailyNotesByCondition(
      fromDate: startOfWeek,
      toDate: now,
    );
  }

  // 获取本月的日常点滴
  Future<List<DailyNote>> getThisMonthDailyNotes() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return getDailyNotesByCondition(
      fromDate: startOfMonth,
      toDate: now,
    );
  }

  // 获取本季度的日常点滴
  Future<List<DailyNote>> getThisQuarterDailyNotes() async {
    final now = DateTime.now();
    // 计算当前季度的第一个月
    final quarterFirstMonth = ((now.month - 1) ~/ 3) * 3 + 1;
    final startOfQuarter = DateTime(now.year, quarterFirstMonth, 1);

    return getDailyNotesByCondition(
      fromDate: startOfQuarter,
      toDate: now,
    );
  }

  // 获取最近三天的日常点滴（今天、昨天、前天）
  Future<List<DailyNote>> getRecentThreeDaysDailyNotes() async {
    final now = DateTime.now();
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final startOfTwoDaysAgo =
        DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day);

    return getDailyNotesByCondition(
      fromDate: startOfTwoDaysAgo,
      toDate: now,
    );
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 设置错误信息
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // 清除错误信息
  void _clearError() {
    _error = null;
  }

  // 获取所有日常点滴数量
  Future<int> getAllDailyNotesCount() async {
    final notes = await getDailyNotesByCondition();
    return notes.length;
  }

  // 获取今日日常点滴数量
  Future<int> getTodayDailyNotesCount() async {
    final notes = await getTodayDailyNotes();
    return notes.length;
  }

  // 获取本周日常点滴数量
  Future<int> getThisWeekDailyNotesCount() async {
    final notes = await getThisWeekDailyNotes();
    return notes.length;
  }

  // 获取本月日常点滴数量
  Future<int> getThisMonthDailyNotesCount() async {
    final notes = await getThisMonthDailyNotes();
    return notes.length;
  }

  // 获取本季度日常点滴数量
  Future<int> getThisQuarterDailyNotesCount() async {
    final notes = await getThisQuarterDailyNotes();
    return notes.length;
  }

  // 获取日常点滴统计信息
  Future<Map<String, int>> getDailyNoteStatistics() async {
    final allCount = await getAllDailyNotesCount();
    final todayCount = await getTodayDailyNotesCount();
    final weekCount = await getThisWeekDailyNotesCount();
    final monthCount = await getThisMonthDailyNotesCount();
    final quarterCount = await getThisQuarterDailyNotesCount();

    return {
      'total': allCount,
      'today': todayCount,
      'week': weekCount,
      'month': monthCount,
      'quarter': quarterCount,
    };
  }
}
