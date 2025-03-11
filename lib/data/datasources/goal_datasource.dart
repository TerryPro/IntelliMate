 import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/goal_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class GoalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 创建目标
  Future<GoalModel> createGoal(GoalModel goal) async {
    final db = await _databaseHelper.database;
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final GoalModel newGoal = goal.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    await db.insert(
      DatabaseHelper.tableGoal,
      newGoal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return newGoal;
  }

  // 获取所有目标
  Future<List<GoalModel>> getAllGoals() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableGoal,
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return GoalModel.fromMap(maps[i]);
    });
  }

  // 按类别获取目标
  Future<List<GoalModel>> getGoalsByCategory(String category) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableGoal,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return GoalModel.fromMap(maps[i]);
    });
  }

  // 按状态获取目标
  Future<List<GoalModel>> getGoalsByStatus(String status) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableGoal,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return GoalModel.fromMap(maps[i]);
    });
  }

  // 按ID获取目标
  Future<GoalModel?> getGoalById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableGoal,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return GoalModel.fromMap(maps.first);
  }

  // 更新目标
  Future<int> updateGoal(GoalModel goal) async {
    final db = await _databaseHelper.database;
    
    // 更新时间戳
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedGoal = goal.copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    return await db.update(
      DatabaseHelper.tableGoal,
      updatedGoal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // 更新目标进度
  Future<int> updateGoalProgress(String id, double progress) async {
    final goal = await getGoalById(id);
    if (goal == null) return 0;
    
    final updatedGoal = goal.copyWith(progress: progress);
    return await updateGoal(updatedGoal);
  }

  // 更新目标状态
  Future<int> updateGoalStatus(String id, String status) async {
    final goal = await getGoalById(id);
    if (goal == null) return 0;
    
    final updatedGoal = goal.copyWith(status: status);
    return await updateGoal(updatedGoal);
  }

  // 删除目标
  Future<int> deleteGoal(String id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableGoal,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 搜索目标
  Future<List<GoalModel>> searchGoals(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableGoal,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return GoalModel.fromMap(maps[i]);
    });
  }
}