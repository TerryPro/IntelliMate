import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class UpdateMemo {
  final MemoRepository repository;

  UpdateMemo(this.repository);

  Future<bool> call(Memo memo) async {
    return await repository.updateMemo(memo);
  }
} 