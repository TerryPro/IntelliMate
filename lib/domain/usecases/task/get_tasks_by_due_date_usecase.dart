import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class GetTasksByDueDateUseCase {
  final TaskRepository repository;

  GetTasksByDueDateUseCase(this.repository);

  Future<Result<List<TaskModel>>> call(DateTime dueDate) async {
    try {
      return await repository.getTasksByDueDate(dueDate);
    } catch (e) {
      return Result.failure("获取截止日期任务失败: $e");
    }
  }
} 