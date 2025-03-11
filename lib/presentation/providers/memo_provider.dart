import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/usecases/memo/create_memo.dart';
import 'package:intellimate/domain/usecases/memo/delete_memo.dart';
import 'package:intellimate/domain/usecases/memo/get_all_memos.dart';
import 'package:intellimate/domain/usecases/memo/get_completed_memos.dart';
import 'package:intellimate/domain/usecases/memo/get_memo_by_id.dart';
import 'package:intellimate/domain/usecases/memo/get_memos_by_category.dart';
import 'package:intellimate/domain/usecases/memo/get_memos_by_date.dart';
import 'package:intellimate/domain/usecases/memo/get_memos_by_priority.dart';
import 'package:intellimate/domain/usecases/memo/get_pinned_memos.dart';
import 'package:intellimate/domain/usecases/memo/get_uncompleted_memos.dart';
import 'package:intellimate/domain/usecases/memo/search_memos.dart';
import 'package:intellimate/domain/usecases/memo/update_memo.dart';

class MemoProvider extends ChangeNotifier {
  final GetMemoById _getMemoByIdUseCase;
  final CreateMemo _createMemoUseCase;
  final UpdateMemo _updateMemoUseCase;
  final DeleteMemo _deleteMemoUseCase;
  final GetAllMemos _getAllMemosUseCase;
  final GetMemosByDate _getMemosByDateUseCase;
  final GetCompletedMemos _getCompletedMemosUseCase;
  final GetUncompletedMemos _getUncompletedMemosUseCase;
  final GetMemosByPriority _getMemosByPriorityUseCase;
  final GetPinnedMemos _getPinnedMemosUseCase;
  final SearchMemos _searchMemosUseCase;
  final GetMemosByCategory _getMemosByCategoryUseCase;

  MemoProvider({
    required GetMemoById getMemoByIdUseCase,
    required CreateMemo createMemoUseCase,
    required UpdateMemo updateMemoUseCase,
    required DeleteMemo deleteMemoUseCase,
    required GetAllMemos getAllMemosUseCase,
    required GetMemosByDate getMemosByDateUseCase,
    required GetCompletedMemos getCompletedMemosUseCase,
    required GetUncompletedMemos getUncompletedMemosUseCase,
    required GetMemosByPriority getMemosByPriorityUseCase,
    required GetPinnedMemos getPinnedMemosUseCase,
    required SearchMemos searchMemosUseCase,
    required GetMemosByCategory getMemosByCategoryUseCase,
  }) : _getMemoByIdUseCase = getMemoByIdUseCase,
       _createMemoUseCase = createMemoUseCase,
       _updateMemoUseCase = updateMemoUseCase,
       _deleteMemoUseCase = deleteMemoUseCase,
       _getAllMemosUseCase = getAllMemosUseCase,
       _getMemosByDateUseCase = getMemosByDateUseCase,
       _getCompletedMemosUseCase = getCompletedMemosUseCase,
       _getUncompletedMemosUseCase = getUncompletedMemosUseCase,
       _getMemosByPriorityUseCase = getMemosByPriorityUseCase,
       _getPinnedMemosUseCase = getPinnedMemosUseCase,
       _searchMemosUseCase = searchMemosUseCase,
       _getMemosByCategoryUseCase = getMemosByCategoryUseCase;

  // 状态变量
  bool _isLoading = false;
  String? _error;
  List<Memo> _memos = [];
  Memo? _selectedMemo;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Memo> get memos => _memos;
  Memo? get selectedMemo => _selectedMemo;

  // 根据ID获取备忘
  Future<Memo?> getMemoById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memo = await _getMemoByIdUseCase(id);
      _selectedMemo = memo;
      _isLoading = false;
      notifyListeners();
      return memo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 创建备忘
  Future<Memo?> createMemo({
    required String title,
    required String content,
    required DateTime date,
    String? category,
    required String priority,
    required bool isPinned,
    required bool isCompleted,
    DateTime? completedAt,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memo = await _createMemoUseCase(
        title: title,
        content: content,
        date: date,
        category: category,
        priority: priority,
        isPinned: isPinned,
        isCompleted: isCompleted,
        completedAt: completedAt,
      );
      
      // 更新状态
      _memos = [..._memos, memo];
      _isLoading = false;
      notifyListeners();
      return memo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 更新备忘
  Future<bool> updateMemo(Memo memo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _updateMemoUseCase(memo);
      
      if (success) {
        // 更新本地列表
        final index = _memos.indexWhere((m) => m.id == memo.id);
        if (index != -1) {
          _memos[index] = memo;
        }
        
        // 如果是当前选中的备忘，也更新它
        if (_selectedMemo?.id == memo.id) {
          _selectedMemo = memo;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 删除备忘
  Future<bool> deleteMemo(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _deleteMemoUseCase(id);
      
      if (success) {
        // 从列表中移除
        _memos.removeWhere((memo) => memo.id == id);
        
        // 如果是当前选中的备忘，清除选中状态
        if (_selectedMemo?.id == id) {
          _selectedMemo = null;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 获取所有备忘
  Future<List<Memo>> getAllMemos({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _getAllMemosUseCase(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      
      _memos = memos;
      _isLoading = false;
      notifyListeners();
      return memos;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 按日期获取备忘
  Future<List<Memo>> getMemosByDate(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _getMemosByDateUseCase(date);
      
      _memos = memos;
      _isLoading = false;
      notifyListeners();
      return memos;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 获取已完成的备忘
  Future<List<Memo>> getCompletedMemos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _getCompletedMemosUseCase();
      
      _memos = memos;
      _isLoading = false;
      notifyListeners();
      return memos;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 获取未完成的备忘
  Future<List<Memo>> getUncompletedMemos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _getUncompletedMemosUseCase();
      
      _memos = memos;
      _isLoading = false;
      notifyListeners();
      return memos;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 按优先级获取备忘
  Future<List<Memo>> getMemosByPriority(String priority) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _getMemosByPriorityUseCase(priority);
      
      _memos = memos;
      _isLoading = false;
      notifyListeners();
      return memos;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 获取置顶备忘
  Future<List<Memo>> getPinnedMemos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _getPinnedMemosUseCase();
      
      _memos = memos;
      _isLoading = false;
      notifyListeners();
      return memos;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 搜索备忘
  Future<List<Memo>> searchMemos(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _searchMemosUseCase(query);
      
      _memos = memos;
      _isLoading = false;
      notifyListeners();
      return memos;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 按类别获取备忘
  Future<List<Memo>> getMemosByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _getMemosByCategoryUseCase(category);
      
      _memos = memos;
      _isLoading = false;
      notifyListeners();
      return memos;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 设置选中的备忘
  void setSelectedMemo(Memo? memo) {
    _selectedMemo = memo;
    notifyListeners();
  }
} 