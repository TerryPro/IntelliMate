import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/domain/entities/memo.dart';

class GetMemosByCategory {
  final MemoRepository repository;

  GetMemosByCategory(this.repository);

  Future<Result<List<Memo>>> call(String category) async {
    try {
      return await repository.getMemosByCategory(category);
    } catch (e) {
      return Result.failure("获取分类备忘录失败: $e");
    }
  }
}
