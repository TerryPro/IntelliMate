import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class GetTaskByIdUseCase {
  final TaskRepository repository;

  GetTaskByIdUseCase(this.repository);

  Future<Result<TaskModel>> call(String id) async {
    try {
      return await repository.getTaskById(id);
    } catch (e) {
      return Result.failure("获取任务详情失败: $e");
    }
  }
} 