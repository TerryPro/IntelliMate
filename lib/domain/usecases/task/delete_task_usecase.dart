import 'package:intellimate/domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<bool> execute(String id) async {
    return await repository.deleteTask(id);
  }
} 