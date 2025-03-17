import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/usecases/memo/create_memo.dart';
import 'package:intellimate/domain/usecases/memo/delete_memo.dart';
import 'package:intellimate/domain/usecases/memo/get_all_memos.dart';
import 'package:intellimate/domain/usecases/memo/get_memo_by_id.dart';
import 'package:intellimate/domain/usecases/memo/get_memos_by_category.dart';
import 'package:intellimate/domain/usecases/memo/search_memos.dart';
import 'package:intellimate/domain/usecases/memo/update_memo.dart';

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

    final result = await _getMemoByIdUseCase(id);
    _isLoading = false;

    result.fold(
      onSuccess: (memo) {
        _selectedMemo = memo;
        _error = null;
      },
      onFailure: (error) {
        _error = error;
      },
    );

    notifyListeners();
    return result.isSuccess ? result.data : null;
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

    // 数据验证
    if (title.trim().isEmpty) {
      _error = '标题不能为空';
      _isLoading = false;
      notifyListeners();
      return null;
    }
    if (content.trim().isEmpty) {
      _error = '内容不能为空';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final result = await _createMemoUseCase(
      title: title.trim(),
      content: content.trim(),
      category: category?.trim(),
    );

    _isLoading = false;

    result.fold(
      onSuccess: (memo) {
        _memos = [..._memos, memo];
        _error = null;
      },
      onFailure: (error) {
        _error = error;
      },
    );

    notifyListeners();
    return result.isSuccess ? result.data : null;
  }

  // 更新备忘
  Future<bool> updateMemo(Memo memo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _updateMemoUseCase(memo);
    _isLoading = false;

    result.fold(
      onSuccess: (updatedMemo) {
        // 更新本地列表
        final index = _memos.indexWhere((m) => m.id == updatedMemo.id);
        if (index != -1) {
          _memos[index] = updatedMemo;
        }

        // 如果是当前选中的备忘，也更新它
        if (_selectedMemo?.id == updatedMemo.id) {
          _selectedMemo = updatedMemo;
        }
        _error = null;
      },
      onFailure: (error) {
        _error = error;
      },
    );

    notifyListeners();
    return result.isSuccess;
  }

  // 删除备忘
  Future<bool> deleteMemo(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _deleteMemoUseCase(id);
    _isLoading = false;

    result.fold(
      onSuccess: (_) {
        // 从列表中移除
        _memos.removeWhere((memo) => memo.id == id);

        // 如果是当前选中的备忘，清除选中状态
        if (_selectedMemo?.id == id) {
          _selectedMemo = null;
        }
        _error = null;
      },
      onFailure: (error) {
        _error = error;
      },
    );

    notifyListeners();
    return result.isSuccess;
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

    final result = await _getAllMemosUseCase(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );

    _isLoading = false;

    result.fold(
      onSuccess: (memos) {
        _memos = memos;
        _error = null;
      },
      onFailure: (error) {
        _error = error;
      },
    );

    notifyListeners();
    return result.isSuccess ? result.data ?? [] : [];
  }

  // 搜索备忘
  Future<List<Memo>> searchMemos(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _searchMemosUseCase(query);
    _isLoading = false;

    result.fold(
      onSuccess: (memos) {
        _error = null;
      },
      onFailure: (error) {
        _error = error;
      },
    );

    notifyListeners();
    return result.isSuccess ? result.data ?? [] : [];
  }

  // 按类别获取备忘
  Future<List<Memo>> getMemosByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getMemosByCategoryUseCase(category);
    _isLoading = false;

    result.fold(
      onSuccess: (memos) {
        _error = null;
      },
      onFailure: (error) {
        _error = error;
      },
    );

    notifyListeners();
    return result.isSuccess ? result.data ?? [] : [];
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
