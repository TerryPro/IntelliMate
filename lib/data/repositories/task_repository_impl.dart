import 'package:intellimate/data/datasources/task_datasource.dart';
import 'package:intellimate/data/models/task_model.dart';
import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource dataSource;

  TaskRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<TaskModel>>> getAllTasks({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      final tasks = await dataSource.getAllTasks(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      return Result.success(tasks);
    } catch (e) {
      return Result.failure("获取所有任务失败: $e");
    }
  }

  @override
  Future<Result<TaskModel>> getTaskById(String id) async {
    try {
      final task = await dataSource.getTaskById(id);
      if (task == null) {
        return Result.failure("找不到ID为$id的任务");
      }
      return Result.success(task);
    } catch (e) {
      return Result.failure("获取任务详情失败: $e");
    }
  }

  @override
  Future<Result<TaskModel>> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? category,
    int? priority,
  }) async {
    try {
      final now = DateTime.now();
      final taskModel = TaskModel(
        id: '', // 会在数据源中生成
        title: title,
        description: description,
        dueDate: dueDate,
        isCompleted: false,
        category: category,
        priority: priority,
        createdAt: now,
        updatedAt: now,
      );
      
      final result = await dataSource.createTask(taskModel);
      return Result.success(result);
    } catch (e) {
      return Result.failure("创建任务失败: $e");
    }
  }

  @override
  Future<Result<TaskModel>> updateTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final affected = await dataSource.updateTask(taskModel);
      if (affected > 0) {
        return Result.success(taskModel);
      } else {
        return Result.failure("更新任务失败: 没有任务被更新");
      }
    } catch (e) {
      return Result.failure("更新任务失败: $e");
    }
  }

  @override
  Future<Result<bool>> deleteTask(String id) async {
    try {
      final affected = await dataSource.deleteTask(id);
      if (affected > 0) {
        return Result.success(true);
      } else {
        return Result.failure("删除任务失败: 没有任务被删除");
      }
    } catch (e) {
      return Result.failure("删除任务失败: $e");
    }
  }

  @override
  Future<Result<List<TaskModel>>> searchTasks(String query) async {
    try {
      final tasks = await dataSource.searchTasks(query);
      return Result.success(tasks);
    } catch (e) {
      return Result.failure("搜索任务失败: $e");
    }
  }

  @override
  Future<Result<List<TaskModel>>> getCompletedTasks() async {
    try {
      final tasks = await dataSource.getCompletedTasks();
      return Result.success(tasks);
    } catch (e) {
      return Result.failure("获取已完成任务失败: $e");
    }
  }

  @override
  Future<Result<List<TaskModel>>> getIncompleteTasks() async {
    try {
      final tasks = await dataSource.getIncompleteTasks();
      return Result.success(tasks);
    } catch (e) {
      return Result.failure("获取未完成任务失败: $e");
    }
  }

  @override
  Future<Result<List<TaskModel>>> getTasksByCategory(String category) async {
    try {
      final tasks = await dataSource.getTasksByCategory(category);
      return Result.success(tasks);
    } catch (e) {
      return Result.failure("获取分类任务失败: $e");
    }
  }

  @override
  Future<Result<List<TaskModel>>> getTasksByPriority(int priority) async {
    try {
      final tasks = await dataSource.getTasksByPriority(priority);
      return Result.success(tasks);
    } catch (e) {
      return Result.failure("获取优先级任务失败: $e");
    }
  }

  @override
  Future<Result<List<TaskModel>>> getTasksByDueDate(DateTime dueDate) async {
    try {
      final tasks = await dataSource.getTasksByDueDate(dueDate);
      return Result.success(tasks);
    } catch (e) {
      return Result.failure("获取截止日期任务失败: $e");
    }
  }

  @override
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
  }) async {
    try {
      final tasks = await dataSource.getTasksByCondition(
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
      return Result.success(tasks);
    } catch (e) {
      return Result.failure("根据条件获取任务失败: $e");
    }
  }
} 