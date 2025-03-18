import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/user_model.dart';
import 'package:intellimate/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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
    try {
      AppLogger.log('获取当前用户信息');
      // 获取当前用户ID
      final currentUserId = await getCurrentUserId();
      AppLogger.log('当前用户ID: $currentUserId');

      if (currentUserId != null && currentUserId.isNotEmpty) {
        try {
          // 根据ID获取用户信息
          final user = await getUserById(currentUserId);
          if (user != null) {
            AppLogger.log('成功获取当前用户: ${user.username}');
            return user;
          } else {
            AppLogger.log('未找到当前用户信息，ID: $currentUserId');
            return null;
          }
        } catch (e) {
          AppLogger.log('获取当前用户详细信息失败: $e');
          AppLogger.log('错误堆栈: ${StackTrace.current}');
          return null;
        }
      } else {
        AppLogger.log('没有当前用户ID，用户未登录');
        return null;
      }
    } catch (e) {
      AppLogger.log('获取用户信息失败: $e');
      AppLogger.log('错误堆栈: ${StackTrace.current}');
      return null;
    }
  }

  // 根据ID获取用户
  Future<UserModel?> getUserById(String id) async {
    try {
      AppLogger.log('根据ID获取用户: $id');
      final db = await DatabaseHelper.instance.database;

      // 查询指定ID的用户
      final results = await db.query(
        DatabaseHelper.tableUser,
        where: 'id = ?',
        whereArgs: [id],
      );

      AppLogger.log('查询结果数量: ${results.length}');

      if (results.isNotEmpty) {
        final userData = results.first;
        AppLogger.log('找到用户数据: $userData');
        try {
          final user = UserModel.fromMap(userData);
          AppLogger.log('成功解析用户数据: ${user.username}');
          return user;
        } catch (e) {
          AppLogger.log('解析用户数据失败: $e');
          AppLogger.log('错误堆栈: ${StackTrace.current}');
          return null;
        }
      } else {
        AppLogger.log('未找到ID为 $id 的用户');
        return null;
      }
    } catch (e) {
      AppLogger.log('根据ID获取用户失败: $e');
      AppLogger.log('错误堆栈: ${StackTrace.current}');
      return null;
    }
  }

  // 创建新用户
  Future<String?> createUser(UserModel user) async {
    try {
      AppLogger.log('准备创建新用户: ${user.username}');
      final db = await DatabaseHelper.instance.database;

      // 准备用户数据
      final userData = user.toMap();
      AppLogger.log('用户数据准备完成: $userData');

      // 插入用户数据
      await db.insert(
        DatabaseHelper.tableUser,
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      AppLogger.log('用户创建成功，ID: ${user.id}');

      // 验证用户是否创建成功
      final createdUser = await getUserById(user.id);
      if (createdUser != null) {
        AppLogger.log('验证用户创建: 成功找到用户 ${createdUser.username}');
      } else {
        AppLogger.log('警告：用户创建后无法验证，可能未成功插入');
      }

      return user.id;
    } catch (e) {
      AppLogger.log('创建用户失败: $e');
      AppLogger.log('错误堆栈: ${StackTrace.current}');
      return null;
    }
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
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseHelper.tableUser);

    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }
}
