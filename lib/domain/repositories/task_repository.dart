import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/task_model.dart';

abstract class TaskRepository {
  /// 获取所有任务
  Future<Result<List<TaskModel>>> getAllTasks({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });

  /// 根据ID获取任务
  Future<Result<TaskModel>> getTaskById(String id);

  /// 创建任务
  Future<Result<TaskModel>> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? category,
    int? priority,
  });

  /// 更新任务
  Future<Result<TaskModel>> updateTask(Task task);

  /// 删除任务
  Future<Result<bool>> deleteTask(String id);

  /// 搜索任务
  Future<Result<List<TaskModel>>> searchTasks(String query);

  /// 获取已完成的任务
  Future<Result<List<TaskModel>>> getCompletedTasks();

  /// 获取未完成的任务
  Future<Result<List<TaskModel>>> getIncompleteTasks();

  /// 根据分类获取任务
  Future<Result<List<TaskModel>>> getTasksByCategory(String category);

  /// 根据优先级获取任务
  Future<Result<List<TaskModel>>> getTasksByPriority(int priority);

  /// 根据截止日期获取任务
  Future<Result<List<TaskModel>>> getTasksByDueDate(DateTime dueDate);

  /// 根据条件获取任务
  Future<Result<List<TaskModel>>> getTasksByCondition({
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