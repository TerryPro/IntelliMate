import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class GetIncompleteTasksUseCase {
  final TaskRepository repository;

  GetIncompleteTasksUseCase(this.repository);

  Future<Result<List<TaskModel>>> call() async {
    try {
      return await repository.getIncompleteTasks();
    } catch (e) {
      return Result.failure("获取未完成任务失败: $e");
    }
  }
} 