import 'package:intellimate/data/datasources/memo_datasource.dart';
import 'package:intellimate/data/models/memo_model.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class MemoRepositoryImpl implements MemoRepository {
  final MemoDataSource _dataSource;

  MemoRepositoryImpl(this._dataSource);

  @override
  Future<Memo?> getMemoById(String id) async {
    return await _dataSource.getMemoById(id);
  }

  @override
  Future<Memo> createMemo({
    required String title,
    required String content,
    String? category,
  }) async {
    final memo = MemoModel(
      id: '', // 会在数据源中生成
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(), // 会在数据源中更新
      updatedAt: DateTime.now(), // 会在数据源中更新
    );

    return await _dataSource.createMemo(memo);
  }

  @override
  Future<bool> updateMemo(Memo memo) async {
    final memoModel = MemoModel.fromEntity(memo);
    final result = await _dataSource.updateMemo(memoModel);
    return result > 0;
  }

  @override
  Future<bool> deleteMemo(String id) async {
    final result = await _dataSource.deleteMemo(id);
    return result > 0;
  }

  @override
  Future<List<Memo>> getAllMemos({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await _dataSource.getAllMemos(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }

  @override
  Future<List<Memo>> searchMemos(String query) async {
    return await _dataSource.searchMemos(query);
  }

  @override
  Future<List<Memo>> getMemosByCategory(String category) async {
    return await _dataSource.getMemosByCategory(category);
  }
}
