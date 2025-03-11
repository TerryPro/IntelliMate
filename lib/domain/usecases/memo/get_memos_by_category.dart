import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class GetMemosByCategory {
  final MemoRepository repository;

  GetMemosByCategory(this.repository);

  Future<List<Memo>> call(String category) async {
    return await repository.getMemosByCategory(category);
  }
} 