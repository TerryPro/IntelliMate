import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class GetPinnedMemos {
  final MemoRepository repository;

  GetPinnedMemos(this.repository);

  Future<List<Memo>> call() async {
    return await repository.getPinnedMemos();
  }
} 