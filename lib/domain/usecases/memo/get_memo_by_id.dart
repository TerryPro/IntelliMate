import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/domain/entities/memo.dart';

class GetMemoById {
  final MemoRepository repository;

  GetMemoById(this.repository);

  Future<Result<Memo>> call(String id) async {
    if (id.isEmpty) {
      return Result.failure('备忘录ID不能为空');
    }
    try {
      return await repository.getMemoById(id);
    } catch (e) {
      return Result.failure('获取备忘录失败: ${e.toString()}');
    }
  }
}
