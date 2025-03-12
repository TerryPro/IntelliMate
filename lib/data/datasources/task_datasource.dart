import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/task_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class TaskDataSource {
  /// 获取所有任务
  Future<List<TaskModel>> getAllTasks({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });

  /// 根据ID获取任务
  Future<TaskModel?> getTaskById(String id);

  /// 创建任务
  Future<TaskModel> createTask(TaskModel task);

  /// 更新任务
  /// 返回受影响的行数
  Future<int> updateTask(TaskModel task);

  /// 删除任务
  /// 返回受影响的行数
  Future<int> deleteTask(String id);

  /// 搜索任务
  Future<List<TaskModel>> searchTasks(String query);

  /// 获取已完成的任务
  Future<List<TaskModel>> getCompletedTasks();

  /// 获取未完成的任务
  Future<List<TaskModel>> getIncompleteTasks();

  /// 根据分类获取任务
  Future<List<TaskModel>> getTasksByCategory(String category);

  /// 根据优先级获取任务
  Future<List<TaskModel>> getTasksByPriority(int priority);

  /// 根据截止日期获取任务
  Future<List<TaskModel>> getTasksByDueDate(DateTime dueDate);

  /// 根据条件获取任务
  Future<List<TaskModel>> getTasksByCondition({
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

class TaskDataSourceImpl extends TaskDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 确保数据库已初始化
  Future<void> _ensureDatabaseReady() async {
    await _databaseHelper.ensureInitialized();
  }

  /// 获取所有任务
  @override
  Future<List<TaskModel>> getAllTasks({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        limit: limit,
        offset: offset,
        orderBy: orderBy ?? 'created_at ${descending ? 'DESC' : 'ASC'}',
      );
      
      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 根据ID获取任务
  @override
  Future<TaskModel?> getTaskById(String id) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }
      
      return TaskModel.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  /// 创建任务
  @override
  Future<TaskModel> createTask(TaskModel task) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final TaskModel newTask = task.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    try {
      
      final result = await db.insert(
        DatabaseHelper.tableTask,
        newTask.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      
      // 验证任务是否真的保存了
      final verifyResult = await db.query(
        DatabaseHelper.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (verifyResult.isNotEmpty) {
      } else {
      }
      
      return newTask;
    } catch (e) {
      rethrow;
    }
  }

  /// 更新任务
  @override
  Future<int> updateTask(TaskModel task) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    // 更新时间戳
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedTask = task.copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    try {
      final result = await db.update(
        DatabaseHelper.tableTask,
        updatedTask.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// 删除任务
  @override
  Future<int> deleteTask(String id) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final result = await db.delete(
        DatabaseHelper.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// 搜索任务
  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      
      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 获取已完成的任务
  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    return getTasksByCondition(isCompleted: true);
  }

  /// 获取未完成的任务
  @override
  Future<List<TaskModel>> getIncompleteTasks() async {
    return getTasksByCondition(isCompleted: false);
  }

  /// 根据分类获取任务
  @override
  Future<List<TaskModel>> getTasksByCategory(String category) async {
    return getTasksByCondition(category: category);
  }

  /// 根据优先级获取任务
  @override
  Future<List<TaskModel>> getTasksByPriority(int priority) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        where: 'priority = ?',
        whereArgs: [priority],
        orderBy: 'created_at DESC',
      );
      
      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 根据截止日期获取任务
  @override
  Future<List<TaskModel>> getTasksByDueDate(DateTime dueDate) async {
    final startOfDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final endOfDay = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59);
    
    return getTasksByCondition(
      fromDate: startOfDay,
      toDate: endOfDay,
    );
  }

  /// 根据条件获取任务
  @override
  Future<List<TaskModel>> getTasksByCondition({
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
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    // 构建查询条件
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];
    
    if (category != null) {
      whereConditions.add('category = ?');
      whereArgs.add(category);
    }
    
    if (isCompleted != null) {
      whereConditions.add('is_completed = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }
    
    if (priority != null) {
      whereConditions.add('priority = ?');
      whereArgs.add(priority);
    }
    
    if (fromDate != null) {
      whereConditions.add('due_date >= ?');
      whereArgs.add(fromDate.millisecondsSinceEpoch);
    }
    
    if (toDate != null) {
      whereConditions.add('due_date <= ?');
      whereArgs.add(toDate.millisecondsSinceEpoch);
    }
    
    // 组合查询条件
    String? whereClause;
    if (whereConditions.isNotEmpty) {
      whereClause = whereConditions.join(' AND ');
    }
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: limit,
        offset: offset,
        orderBy: orderBy ?? 'created_at ${descending ? 'DESC' : 'ASC'}',
      );
      
      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }
} 