import 'package:intellimate/data/datasources/task_datasource.dart';
import 'package:intellimate/data/models/task_model.dart';
import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource dataSource;

  TaskRepositoryImpl({required this.dataSource});

  @override
  Future<List<Task>> getAllTasks({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await dataSource.getAllTasks(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return await dataSource.getTaskById(id);
  }

  @override
  Future<Task> createTask(Task task) async {
    print('TaskRepository: 开始创建任务');
    try {
      final taskModel = TaskModel.fromEntity(task);
      print('TaskRepository: 实体转换为模型成功, 标题: ${taskModel.title}');
      final result = await dataSource.createTask(taskModel);
      print('TaskRepository: 数据源创建任务成功, ID: ${result.id}');
      return result;
    } catch (e) {
      print('TaskRepository: 创建任务失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    final result = await dataSource.updateTask(taskModel);
    return result > 0;
  }

  @override
  Future<bool> deleteTask(String id) async {
    final result = await dataSource.deleteTask(id);
    return result > 0;
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    return await dataSource.searchTasks(query);
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    return await dataSource.getCompletedTasks();
  }

  @override
  Future<List<Task>> getIncompleteTasks() async {
    return await dataSource.getIncompleteTasks();
  }

  @override
  Future<List<Task>> getTasksByCategory(String category) async {
    return await dataSource.getTasksByCategory(category);
  }

  @override
  Future<List<Task>> getTasksByPriority(int priority) async {
    return await dataSource.getTasksByPriority(priority);
  }

  @override
  Future<List<Task>> getTasksByDueDate(DateTime dueDate) async {
    return await dataSource.getTasksByDueDate(dueDate);
  }

  @override
  Future<List<Task>> getTasksByCondition({
    String? category,
    bool? isCompleted,
    int? priority,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await dataSource.getTasksByCondition(
      category: category,
      isCompleted: isCompleted,
      priority: priority,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
} 