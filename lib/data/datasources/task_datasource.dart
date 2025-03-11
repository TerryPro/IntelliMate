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
    print('TaskDataSourceImpl: 获取所有任务');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        limit: limit,
        offset: offset,
        orderBy: orderBy ?? 'created_at ${descending ? 'DESC' : 'ASC'}',
      );
      
      print('TaskDataSourceImpl: 查询成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('TaskDataSourceImpl: 查询失败: $e');
      rethrow;
    }
  }

  /// 根据ID获取任务
  @override
  Future<TaskModel?> getTaskById(String id) async {
    print('TaskDataSourceImpl: 获取任务，ID: $id');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        print('TaskDataSourceImpl: 未找到任务，ID: $id');
        return null;
      }
      
      print('TaskDataSourceImpl: 找到任务，ID: $id');
      return TaskModel.fromMap(maps.first);
    } catch (e) {
      print('TaskDataSourceImpl: 获取任务失败: $e');
      rethrow;
    }
  }

  /// 创建任务
  @override
  Future<TaskModel> createTask(TaskModel task) async {
    print('TaskDataSourceImpl: 开始创建任务');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    print('TaskDataSourceImpl: 数据库连接成功');
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    print('TaskDataSourceImpl: 生成ID $id 和时间戳 $timestamp');
    
    final TaskModel newTask = task.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    print('TaskDataSourceImpl: 创建新任务对象: ${newTask.title}');
    
    try {
      print('TaskDataSourceImpl: 准备插入数据库，表名: ${DatabaseHelper.tableTask}');
      print('TaskDataSourceImpl: 数据内容: ${newTask.toMap()}');
      
      final result = await db.insert(
        DatabaseHelper.tableTask,
        newTask.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('TaskDataSourceImpl: 数据库插入成功，结果: $result');
      
      // 验证任务是否真的保存了
      final verifyResult = await db.query(
        DatabaseHelper.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('TaskDataSourceImpl: 验证结果 - 找到 ${verifyResult.length} 条记录');
      if (verifyResult.isNotEmpty) {
        print('TaskDataSourceImpl: 验证成功 - 找到匹配记录');
      } else {
        print('TaskDataSourceImpl: 验证失败 - 未找到匹配记录！');
      }
      
      return newTask;
    } catch (e) {
      print('TaskDataSourceImpl: 插入失败: $e');
      rethrow;
    }
  }

  /// 更新任务
  @override
  Future<int> updateTask(TaskModel task) async {
    print('TaskDataSourceImpl: 更新任务，ID: ${task.id}');
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
      
      print('TaskDataSourceImpl: 更新任务成功，受影响行数: $result');
      return result;
    } catch (e) {
      print('TaskDataSourceImpl: 更新任务失败: $e');
      rethrow;
    }
  }

  /// 删除任务
  @override
  Future<int> deleteTask(String id) async {
    print('TaskDataSourceImpl: 删除任务，ID: $id');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final result = await db.delete(
        DatabaseHelper.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('TaskDataSourceImpl: 删除任务成功，受影响行数: $result');
      return result;
    } catch (e) {
      print('TaskDataSourceImpl: 删除任务失败: $e');
      rethrow;
    }
  }

  /// 搜索任务
  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    print('TaskDataSourceImpl: 搜索任务，关键词: $query');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      
      print('TaskDataSourceImpl: 搜索成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('TaskDataSourceImpl: 搜索失败: $e');
      rethrow;
    }
  }

  /// 获取已完成的任务
  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    print('TaskDataSourceImpl: 获取已完成任务');
    return getTasksByCondition(isCompleted: true);
  }

  /// 获取未完成的任务
  @override
  Future<List<TaskModel>> getIncompleteTasks() async {
    print('TaskDataSourceImpl: 获取未完成任务');
    return getTasksByCondition(isCompleted: false);
  }

  /// 根据分类获取任务
  @override
  Future<List<TaskModel>> getTasksByCategory(String category) async {
    print('TaskDataSourceImpl: 获取分类任务，分类: $category');
    return getTasksByCondition(category: category);
  }

  /// 根据优先级获取任务
  @override
  Future<List<TaskModel>> getTasksByPriority(int priority) async {
    print('TaskDataSourceImpl: 获取优先级任务，优先级: $priority');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTask,
        where: 'priority = ?',
        whereArgs: [priority],
        orderBy: 'created_at DESC',
      );
      
      print('TaskDataSourceImpl: 查询成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('TaskDataSourceImpl: 查询失败: $e');
      rethrow;
    }
  }

  /// 根据截止日期获取任务
  @override
  Future<List<TaskModel>> getTasksByDueDate(DateTime dueDate) async {
    print('TaskDataSourceImpl: 获取截止日期任务，日期: $dueDate');
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
    print('TaskDataSourceImpl: 根据条件获取任务');
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
      
      print('TaskDataSourceImpl: 查询成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('TaskDataSourceImpl: 查询失败: $e');
      rethrow;
    }
  }
} 