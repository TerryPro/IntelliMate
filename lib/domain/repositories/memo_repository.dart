import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/core/result.dart';

abstract class MemoRepository {
  // 获取单个备忘
  Future<Result<Memo>> getMemoById(String id);

  // 创建备忘
  Future<Result<Memo>> createMemo({
    required String title,
    String? content,
    String? category,
  });

  // 更新备忘
  Future<Result<Memo>> updateMemo(Memo memo);

  // 删除备忘
  Future<Result<bool>> deleteMemo(String id);

  // 获取所有备忘
  Future<Result<List<Memo>>> getAllMemos({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });

  // 搜索备忘
  Future<Result<List<Memo>>> searchMemos(String query);

  // 按类别获取备忘
  Future<Result<List<Memo>>> getMemosByCategory(String category);
}
