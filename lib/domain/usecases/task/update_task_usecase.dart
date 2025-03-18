import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Result<TaskModel>> call(Task task) async {
    try {
      return await repository.updateTask(task);
    } catch (e) {
      return Result.failure("更新任务失败: $e");
    }
  }
} 