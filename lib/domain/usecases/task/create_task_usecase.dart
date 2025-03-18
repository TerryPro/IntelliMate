import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Result<TaskModel>> call({
    required String title,
    String? description,
    DateTime? dueDate,
    String? category,
    int? priority,
  }) async {
    try {
      return await repository.createTask(
        title: title,
        description: description,
        dueDate: dueDate,
        category: category,
        priority: priority,
      );
    } catch (e) {
      return Result.failure("创建任务失败: $e");
    }
  }
} 