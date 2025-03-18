import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class GetTasksByCategoryUseCase {
  final TaskRepository repository;

  GetTasksByCategoryUseCase(this.repository);

  Future<Result<List<TaskModel>>> call(String category) async {
    try {
      return await repository.getTasksByCategory(category);
    } catch (e) {
      return Result.failure("获取分类任务失败: $e");
    }
  }
} 