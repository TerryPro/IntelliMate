import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';

class GetTasksByConditionUseCase {
  final TaskRepository repository;

  GetTasksByConditionUseCase(this.repository);

  Future<List<Task>> execute({
    String? category,
    bool? isCompleted,
    int? priority,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await repository.getTasksByCondition(
      category: category,
      isCompleted: isCompleted,
      priority: priority,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
} 