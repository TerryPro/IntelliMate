import 'package:intellimate/data/datasources/memo_datasource.dart';
import 'package:intellimate/data/models/memo_model.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class MemoRepositoryImpl implements MemoRepository {
  final MemoDataSource _dataSource;

  MemoRepositoryImpl(this._dataSource);

  @override
  Future<Result<MemoModel>> getMemoById(String id) async {
    try {
      final memo = await _dataSource.getMemoById(id);
      if (memo == null) {
        return Result.failure('备忘不存在');
      }
      return Result.success(memo);
    } catch (e) {
      return Result.failure('获取备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<MemoModel>> createMemo({
    required String title,
    required String content,
    String? category,
  }) async {
    try {
      final memo = MemoModel(
        id: '', // 会在数据源中生成
        title: title.trim(),
        content: content.trim(),
        category: category?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _dataSource.createMemo(memo);
      return Result.success(result);
    } catch (e) {
      return Result.failure('创建备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<MemoModel>> updateMemo(Memo memo) async {
    try {
      final memoModel = MemoModel.fromEntity(memo);
      final result = await _dataSource.updateMemo(memoModel);
      if (result > 0) {
        return Result.success(memoModel);
      }
      return Result.failure('更新备忘失败：未找到对应记录');
    } catch (e) {
      return Result.failure('更新备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> deleteMemo(String id) async {
    try {
      final result = await _dataSource.deleteMemo(id);
      if (result > 0) {
        return Result.success(true);
      }
      return Result.failure('删除备忘失败：未找到对应记录');
    } catch (e) {
      return Result.failure('删除备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<MemoModel>>> getAllMemos({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      final memos = await _dataSource.getAllMemos(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      return Result.success(memos.map((m) => m).toList());
    } catch (e) {
      return Result.failure('获取所有备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<MemoModel>>> searchMemos(String query) async {
    try {
      final memos = await _dataSource.searchMemos(query);
      return Result.success(memos.map((m) => m).toList());
    } catch (e) {
      return Result.failure('搜索备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<MemoModel>>> getMemosByCategory(String category) async {
    try {
      final memos = await _dataSource.getMemosByCategory(category);
      return Result.success(memos.map((m) => m).toList());
    } catch (e) {
      return Result.failure('获取分类备忘失败: ${e.toString()}');
    }
  }
}
