import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';

class GetTaskByIdUseCase {
  final TaskRepository repository;

  GetTaskByIdUseCase(this.repository);

  Future<Task?> execute(String id) async {
    return await repository.getTaskById(id);
  }
} 