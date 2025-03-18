import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class GetTasksByPriorityUseCase {
  final TaskRepository repository;

  GetTasksByPriorityUseCase(this.repository);

  Future<Result<List<TaskModel>>> call(int priority) async {
    try {
      return await repository.getTasksByPriority(priority);
    } catch (e) {
      return Result.failure("获取优先级任务失败: $e");
    }
  }
} 