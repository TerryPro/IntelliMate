import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<Result<bool>> call(String id) async {
    try {
      return await repository.deleteTask(id);
    } catch (e) {
      return Result.failure("删除任务失败: $e");
    }
  }
} 