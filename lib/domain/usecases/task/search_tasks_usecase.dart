import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

class SearchTasksUseCase {
  final TaskRepository repository;

  SearchTasksUseCase(this.repository);

  Future<Result<List<TaskModel>>> call(String query) async {
    try {
      return await repository.searchTasks(query);
    } catch (e) {
      return Result.failure("搜索任务失败: $e");
    }
  }
} 