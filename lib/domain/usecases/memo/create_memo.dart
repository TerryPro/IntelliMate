import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class CreateMemo {
  final MemoRepository repository;

  CreateMemo(this.repository);

  Future<Result<Memo>> call({
    required String title,
    String? content,
    String? category,
  }) async {
    try {
      return await repository.createMemo(
        title: title,
        content: content,
        category: category,
      );
    } catch (e) {
      return Result.failure("创建备忘录失败: $e");
    }
  }
}
