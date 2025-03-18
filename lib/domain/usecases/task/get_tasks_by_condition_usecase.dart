import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class GetTasksByConditionUseCase {
  final TaskRepository repository;

  GetTasksByConditionUseCase(this.repository);

  Future<Result<List<TaskModel>>> call({
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
    try {
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
    } catch (e) {
      return Result.failure("根据条件获取任务失败: $e");
    }
  }
} 