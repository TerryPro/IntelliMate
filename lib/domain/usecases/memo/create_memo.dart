import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class CreateMemo {
  final MemoRepository repository;

  CreateMemo(this.repository);

  Future<Memo> call({
    required String title,
    required String content,
    String? category,
  }) async {
    return await repository.createMemo(
      title: title,
      content: content,
      category: category,
    );
  }
} 