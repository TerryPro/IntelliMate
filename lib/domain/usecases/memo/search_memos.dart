import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class SearchMemos {
  final MemoRepository repository;

  SearchMemos(this.repository);

  Future<List<Memo>> call(String query) async {
    return await repository.searchMemos(query);
  }
} 