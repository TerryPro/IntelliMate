import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';

class GetAllTasksUseCase {
  final TaskRepository repository;

  GetAllTasksUseCase(this.repository);

  Future<List<Task>> execute({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await repository.getAllTasks(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
} 