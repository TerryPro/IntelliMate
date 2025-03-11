import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class GetMemosByPriority {
  final MemoRepository repository;

  GetMemosByPriority(this.repository);

  Future<List<Memo>> call(String priority) async {
    return await repository.getMemosByPriority(priority);
  }
} 