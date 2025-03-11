import 'package:intellimate/domain/entities/task.dart';

abstract class TaskRepository {
  /// 获取所有任务
  Future<List<Task>> getAllTasks({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });

  /// 根据ID获取任务
  Future<Task?> getTaskById(String id);

  /// 创建任务
  Future<Task> createTask(Task task);

  /// 更新任务
  /// 返回是否更新成功
  Future<bool> updateTask(Task task);

  /// 删除任务
  /// 返回是否删除成功
  Future<bool> deleteTask(String id);

  /// 搜索任务
  Future<List<Task>> searchTasks(String query);

  /// 获取已完成的任务
  Future<List<Task>> getCompletedTasks();

  /// 获取未完成的任务
  Future<List<Task>> getIncompleteTasks();

  /// 根据分类获取任务
  Future<List<Task>> getTasksByCategory(String category);

  /// 根据优先级获取任务
  Future<List<Task>> getTasksByPriority(int priority);

  /// 根据截止日期获取任务
  Future<List<Task>> getTasksByDueDate(DateTime dueDate);

  /// 根据条件获取任务
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
  });
} 