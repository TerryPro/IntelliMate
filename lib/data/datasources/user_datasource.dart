import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class UserDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  // 使用SharedPreferences存储当前登录用户的ID
  static const String _currentUserKey = 'current_user_id';

  // 获取当前用户ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // 设置当前用户ID
  Future<bool> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_currentUserKey, userId);
  }

  // 清除当前用户ID（登出）
  Future<bool> clearCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_currentUserKey);
  }

  // 获取当前用户信息
  Future<UserModel?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;
    return getUserById(userId);
  }

  // 根据ID获取用户
  Future<UserModel?> getUserById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUser,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  // 创建用户
  Future<UserModel> createUser(UserModel user) async {
    final db = await _databaseHelper.database;
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final UserModel newUser = user.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    await db.insert(
      DatabaseHelper.tableUser,
      newUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // 设置为当前用户
    await setCurrentUserId(id);
    
    return newUser;
  }

  // 更新用户信息
  Future<int> updateUser(UserModel user) async {
    final db = await _databaseHelper.database;
    
    // 更新时间戳
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedUser = user.copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    return await db.update(
      DatabaseHelper.tableUser,
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // 删除用户
  Future<int> deleteUser(String id) async {
    final db = await _databaseHelper.database;
    
    // 如果删除的是当前用户，清除当前用户ID
    final currentUserId = await getCurrentUserId();
    if (currentUserId == id) {
      await clearCurrentUserId();
    }
    
    return await db.delete(
      DatabaseHelper.tableUser,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取所有用户
  Future<List<UserModel>> getAllUsers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableUser);
    
    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }
}