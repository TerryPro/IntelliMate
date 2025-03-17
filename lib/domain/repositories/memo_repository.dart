import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/memo_model.dart';

abstract class MemoRepository {
  // 获取单个备忘
  Future<Result<MemoModel>> getMemoById(String id);

  // 创建备忘
  Future<Result<MemoModel>> createMemo({
    required String title,
    required String content,
    String? category,
  });

  // 更新备忘
  Future<Result<MemoModel>> updateMemo(Memo memo);

  // 删除备忘
  Future<Result<bool>> deleteMemo(String id);

  // 获取所有备忘
  Future<Result<List<MemoModel>>> getAllMemos({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });

  // 搜索备忘
  Future<Result<List<MemoModel>>> searchMemos(String query);

  // 按类别获取备忘
  Future<Result<List<MemoModel>>> getMemosByCategory(String category);
}
