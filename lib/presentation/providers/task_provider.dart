import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/domain/usecases/task/create_task_usecase.dart';
import 'package:intellimate/domain/usecases/task/delete_task_usecase.dart';
import 'package:intellimate/domain/usecases/task/get_all_tasks_usecase.dart';
import 'package:intellimate/domain/usecases/task/get_task_by_id_usecase.dart';
import 'package:intellimate/domain/usecases/task/get_tasks_by_condition_usecase.dart';
import 'package:intellimate/domain/usecases/task/update_task_usecase.dart';
import 'package:uuid/uuid.dart';
import 'package:intellimate/data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final CreateTaskUseCase _createTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final GetAllTasksUseCase _getAllTasksUseCase;
  final GetTaskByIdUseCase _getTaskByIdUseCase;
  final GetTasksByConditionUseCase _getTasksByConditionUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;

  TaskProvider({
    required CreateTaskUseCase createTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required GetAllTasksUseCase getAllTasksUseCase,
    required GetTaskByIdUseCase getTaskByIdUseCase,
    required GetTasksByConditionUseCase getTasksByConditionUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
  })  : _createTaskUseCase = createTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _getAllTasksUseCase = getAllTasksUseCase,
        _getTaskByIdUseCase = getTaskByIdUseCase,
        _getTasksByConditionUseCase = getTasksByConditionUseCase,
        _updateTaskUseCase = updateTaskUseCase;

  // 任务列表
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 错误信息
  String? _error;
  String? get error => _error;

  // 初始化加载所有任务
  Future<void> loadTasks() async {
    _setLoading(true);
    _clearError();

    try {
      _tasks = await _getAllTasksUseCase.execute();
      notifyListeners();
    } catch (e) {
      _setError('加载任务失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 根据ID获取任务
  Future<Task?> getTaskById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final task = await _getTaskByIdUseCase.execute(id);
      return task;
    } catch (e) {
      _setError('获取任务失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 创建任务
  Future<Task?> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    bool isCompleted = false,
    String? category,
    int? priority,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // 创建临时ID，实际ID将由数据库生成
      final tempId = const Uuid().v4();
      final now = DateTime.now();

      final task = Task(
        id: tempId,
        title: title,
        description: description,
        dueDate: dueDate,
        isCompleted: isCompleted,
        category: category,
        priority: priority,
        createdAt: now,
        updatedAt: now,
      );

      final createdTask = await _createTaskUseCase.execute(task);
      _tasks.add(createdTask);
      notifyListeners();
      return createdTask;
    } catch (e) {
      _setError('创建任务失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 更新任务
  Future<bool> updateTask(Task task) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _updateTaskUseCase.execute(task);
      if (success) {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          final taskModel = TaskModel.fromEntity(task);
          _tasks[index] = taskModel;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('更新任务失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 删除任务
  Future<bool> deleteTask(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _deleteTaskUseCase.execute(id);
      if (success) {
        _tasks.removeWhere((task) => task.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('删除任务失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 根据条件获取任务
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
    _setLoading(true);
    _clearError();

    try {
      final tasks = await _getTasksByConditionUseCase.execute(
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
      return tasks;
    } catch (e) {
      _setError('获取任务失败: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // 获取已完成的任务
  Future<List<Task>> getCompletedTasks() async {
    return getTasksByCondition(isCompleted: true);
  }

  // 获取未完成的任务
  Future<List<Task>> getIncompleteTasks() async {
    return getTasksByCondition(isCompleted: false);
  }

  // 获取今日到期的任务
  Future<List<Task>> getTodayTasks() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getTasksByCondition(
      fromDate: startOfDay,
      toDate: endOfDay,
    );
  }

  // 获取逾期任务
  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();
    return getTasksByCondition(
      isCompleted: false,
      toDate: now,
    );
  }

  // 更新任务完成状态
  Future<bool> updateTaskCompletion(String id, bool isCompleted) async {
    final task = await getTaskById(id);
    if (task == null) return false;

    try {
      // 创建一个新的Task对象，因为Task是不可变的
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        isCompleted: isCompleted,
        category: task.category,
        priority: task.priority,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
      );

      // 调用用例进行更新
      final success = await _updateTaskUseCase.execute(updatedTask);
      
      if (success) {
        // 手动更新本地列表中的任务
        final index = _tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          final taskModel = TaskModel.fromEntity(updatedTask);
          _tasks[index] = taskModel;
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      _setError('更新任务状态失败: $e');
      return false;
    }
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 设置错误信息
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // 清除错误信息
  void _clearError() {
    _error = null;
  }
}