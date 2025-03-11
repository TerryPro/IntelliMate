import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';

class CreateMemo {
  final MemoRepository repository;

  CreateMemo(this.repository);

  Future<Memo> call({
    required String title,
    required String content,
    required DateTime date,
    String? category,
    required String priority,
    required bool isPinned,
    required bool isCompleted,
    DateTime? completedAt,
  }) async {
    return await repository.createMemo(
      title: title,
      content: content,
      date: date,
      category: category,
      priority: priority,
      isPinned: isPinned,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }
} 