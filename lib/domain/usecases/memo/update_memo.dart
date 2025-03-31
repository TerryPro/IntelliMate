import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class UpdateMemo {
  final MemoRepository repository;

  UpdateMemo(this.repository);

  Future<Result<Memo>> call(Memo memo) async {
    try {
      return await repository.updateMemo(memo);
    } catch (e) {
      return Result.failure("更新备忘录失败: $e");
    }
  }
}
