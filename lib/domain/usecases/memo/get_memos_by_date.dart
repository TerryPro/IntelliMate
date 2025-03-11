import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class GetMemosByDate {
  final MemoRepository repository;

  GetMemosByDate(this.repository);

  Future<List<Memo>> call(DateTime date) async {
    return await repository.getMemosByDate(date);
  }
} 