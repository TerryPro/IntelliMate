import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/memo_model.dart';

class SearchMemos {
  final MemoRepository repository;

  SearchMemos(this.repository);

  Future<Result<List<MemoModel>>> call(String query) async {
    try {
      return await repository.searchMemos(query);
    } catch (e) {
      return Result.failure("搜索备忘录失败: $e");
    }
  }
}
