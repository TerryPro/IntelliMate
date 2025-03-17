import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/usecases/memo/create_memo.dart';
import 'package:intellimate/domain/usecases/memo/delete_memo.dart';
import 'package:intellimate/domain/usecases/memo/get_all_memos.dart';
import 'package:intellimate/domain/usecases/memo/get_memo_by_id.dart';
import 'package:intellimate/domain/usecases/memo/get_memos_by_category.dart';
import 'package:intellimate/domain/usecases/memo/search_memos.dart';
import 'package:intellimate/domain/usecases/memo/update_memo.dart';
import 'package:intellimate/data/models/memo_model.dart';

class MemoProvider extends ChangeNotifier {
  final CreateMemo _createMemoUseCase;
  final DeleteMemo _deleteMemoUseCase;
  final GetAllMemos _getAllMemosUseCase;
  final GetMemoById _getMemoByIdUseCase;
  final GetMemosByCategory _getMemosByCategoryUseCase;
  final SearchMemos _searchMemosUseCase;
  final UpdateMemo _updateMemoUseCase;

  MemoProvider({
    required CreateMemo createMemoUseCase,
    required DeleteMemo deleteMemoUseCase,
    required GetAllMemos getAllMemosUseCase,
    required GetMemoById getMemoByIdUseCase,
    required GetMemosByCategory getMemosByCategoryUseCase,
    required SearchMemos searchMemosUseCase,
    required UpdateMemo updateMemoUseCase,
  })  : _createMemoUseCase = createMemoUseCase,
        _deleteMemoUseCase = deleteMemoUseCase,
        _getAllMemosUseCase = getAllMemosUseCase,
        _getMemoByIdUseCase = getMemoByIdUseCase,
        _getMemosByCategoryUseCase = getMemosByCategoryUseCase,
        _searchMemosUseCase = searchMemosUseCase,
        _updateMemoUseCase = updateMemoUseCase;

  // 状态
  List<Memo> _memos = [];
  List<Memo> get memos => _memos;

  Memo? _selectedMemo;
  Memo? get selectedMemo => _selectedMemo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // 获取单个备忘
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
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 数据验证
      if (title.trim().isEmpty) {
        throw Exception('标题不能为空');
      }
      if (content.trim().isEmpty) {
        throw Exception('内容不能为空');
      }

      final memo = await _createMemoUseCase(
        title: title.trim(),
        content: content.trim(),
        category: category?.trim(),
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

    print(memo);
    print(_memos);
    
    try {
      final success = await _updateMemoUseCase(memo);
      if (success) {
        // 更新本地列表
        final index = _memos.indexWhere((m) => m.id == memo.id);
        if (index != -1) {
          try {
            // 将Memo转换为MemoModel
            final memoModel = MemoModel.fromEntity(memo);
            _memos[index] = memoModel;
          } catch (e) {
            print("更新本地列表失败: $e");
            _memos = List.from(_memos); // 回滚状态
            rethrow;
          }
        }

        // 如果是当前选中的备忘，也更新它
        if (_selectedMemo?.id == memo.id) {
          _selectedMemo = memo;
        }
      }

      print("success: $success");

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

  // 搜索备忘
  Future<List<Memo>> searchMemos(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memos = await _searchMemosUseCase(query);
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
