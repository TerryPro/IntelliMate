import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<bool> execute(Task task) async {
    return await repository.updateTask(task);
  }
} 