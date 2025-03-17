import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class DeleteMemo {
  final MemoRepository repository;

  DeleteMemo(this.repository);

  Future<Result<bool>> call(String id) async {
    try {
      return await repository.deleteMemo(id);
    } catch (e) {
      return Result.failure("删除备忘录失败: $e");
    }
  }
}
