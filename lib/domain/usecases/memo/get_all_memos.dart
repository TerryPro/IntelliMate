import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/memo_model.dart';

class GetAllMemos {
  final MemoRepository repository;

  GetAllMemos(this.repository);

  Future<Result<List<MemoModel>>> call({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      return await repository.getAllMemos(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
    } catch (e) {
      return Result.failure("获取所有备忘录失败: " + e.toString());
    }
  }
} 