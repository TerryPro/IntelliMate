import 'package:intellimate/domain/repositories/memo_repository.dart';

class DeleteMemo {
  final MemoRepository repository;

  DeleteMemo(this.repository);

  Future<bool> call(String id) async {
    return await repository.deleteMemo(id);
  }
} 