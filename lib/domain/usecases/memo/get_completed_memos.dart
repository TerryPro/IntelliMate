import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class GetCompletedMemos {
  final MemoRepository repository;

  GetCompletedMemos(this.repository);

  Future<List<Memo>> call() async {
    return await repository.getCompletedMemos();
  }
} 