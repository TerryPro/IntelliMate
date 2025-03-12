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
        _getDailyNotesWithCodeSnippetsUseCase = getDailyNotesWithCodeSnippetsUseCase,
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
      final result = await _getAllDailyNotesUseCase.execute();
      _dailyNotes = result;
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
      final result = await _getDailyNoteByIdUseCase.execute(id);
      _selectedDailyNote = result;
      return result;
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
      
      final dailyNote = DailyNote(
        id: 'temp_id', // 临时ID，会被数据库替换
        author: author,
        content: content,
        images: images,
        location: location,
        mood: mood,
        weather: weather,
        isPrivate: isPrivate,
        likes: 0,
        comments: 0,
        codeSnippet: codeSnippet,
        createdAt: now,
        updatedAt: now,
      );

      final createdDailyNote = await _createDailyNoteUseCase.execute(dailyNote);
      _dailyNotes.insert(0, createdDailyNote);
      notifyListeners();
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
      final success = await _updateDailyNoteUseCase.execute(dailyNote);
      if (success) {
        final index = _dailyNotes.indexWhere((note) => note.id == dailyNote.id);
        if (index != -1) {
          _dailyNotes[index] = dailyNote;
          notifyListeners();
        }
      } else {
      }
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
      final success = await _deleteDailyNoteUseCase.execute(id);
      if (success) {
        _dailyNotes.removeWhere((note) => note.id == id);
        notifyListeners();
      } else {
      }
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
      final results = await _searchDailyNotesUseCase.execute(query);
      return results;
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
      final results = await _getPrivateDailyNotesUseCase.execute();
      return results;
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
      final results = await _getDailyNotesWithCodeSnippetsUseCase.execute();
      return results;
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
      final results = await _getDailyNotesByConditionUseCase.execute(
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
      return results;
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
    final endOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    
    return getDailyNotesByCondition(
      fromDate: startOfDay,
      toDate: endOfDay,
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
} 