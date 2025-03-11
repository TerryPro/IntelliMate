import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class GetMemoById {
  final MemoRepository repository;

  GetMemoById(this.repository);

  Future<Memo?> call(String id) async {
    return await repository.getMemoById(id);
  }
} 