import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class GetUncompletedMemos {
  final MemoRepository repository;

  GetUncompletedMemos(this.repository);

  Future<List<Memo>> call() async {
    return await repository.getUncompletedMemos();
  }
} 