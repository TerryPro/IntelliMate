import 'package:intellimate/data/datasources/memo_datasource.dart';
import 'package:intellimate/data/models/memo_model.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class MemoRepositoryImpl implements MemoRepository {
  // 将MemoModel转换为Memo实体
  Memo _convertToEntity(MemoModel model) {
    return Memo(
      id: model.id,
      title: model.title,
      content: model.content,
      category: model.category,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
  final MemoDataSource _dataSource;

  MemoRepositoryImpl(this._dataSource);

  @override
  Future<Result<Memo>> getMemoById(String id) async {
    try {
      final memoModel = await _dataSource.getMemoById(id);
      if (memoModel == null) {
        return Result.failure('备忘不存在');
      }
      // 返回领域实体而非数据模型
      return Result.success(_convertToEntity(memoModel));
    } catch (e) {
      return Result.failure('获取备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<Memo>> createMemo({
    required String title,
    String? content,
    String? category,
  }) async {
    try {
      final memo = MemoModel(
        id: '', // 会在数据源中生成
        title: title.trim(),
        content: content?.trim(),
        category: category?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _dataSource.createMemo(memo);
      // 返回领域实体而非数据模型
      return Result.success(_convertToEntity(result));
    } catch (e) {
      return Result.failure('创建备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<Memo>> updateMemo(Memo memo) async {
    try {
      final memoModel = MemoModel.fromEntity(memo);
      final result = await _dataSource.updateMemo(memoModel);
      if (result > 0) {
        // 返回领域实体而非数据模型
        return Result.success(_convertToEntity(memoModel));
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
  Future<Result<List<Memo>>> getAllMemos({
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
      // 返回领域实体列表而非数据模型列表
      return Result.success(memos.map((memo) => _convertToEntity(memo)).toList());
    } catch (e) {
      return Result.failure('获取所有备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Memo>>> searchMemos(String query) async {
    try {
      final memos = await _dataSource.searchMemos(query);
      // 返回领域实体列表而非数据模型列表
      return Result.success(memos.map((memo) => _convertToEntity(memo)).toList());
    } catch (e) {
      return Result.failure('搜索备忘失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Memo>>> getMemosByCategory(String category) async {
    try {
      final memos = await _dataSource.getMemosByCategory(category);
      return Result.success(memos.map((memo) => _convertToEntity(memo)).toList());
    } catch (e) {
      return Result.failure('获取分类备忘失败: ${e.toString()}');
    }
  }
}
