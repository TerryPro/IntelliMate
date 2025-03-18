import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class GetCompletedTasksUseCase {
  final TaskRepository repository;

  GetCompletedTasksUseCase(this.repository);

  Future<Result<List<TaskModel>>> call() async {
    try {
      return await repository.getCompletedTasks();
    } catch (e) {
      return Result.failure("获取已完成任务失败: $e");
    }
  }
} 