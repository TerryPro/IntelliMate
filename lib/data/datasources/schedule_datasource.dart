import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/schedule_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ScheduleDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 根据ID获取日程
  Future<ScheduleModel?> getScheduleById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSchedule,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ScheduleModel.fromMap(maps.first);
  }

  // 创建日程
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final db = await _databaseHelper.database;
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final ScheduleModel newSchedule = schedule.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    await db.insert(
      DatabaseHelper.tableSchedule,
      newSchedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return newSchedule;
  }

  // 更新日程
  Future<int> updateSchedule(ScheduleModel schedule) async {
    final db = await _databaseHelper.database;
    
    // 更新时间戳
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedSchedule = schedule.copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    return await db.update(
      DatabaseHelper.tableSchedule,
      updatedSchedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  // 删除日程
  Future<int> deleteSchedule(String id) async {
    final db = await _databaseHelper.database;
    
    return await db.delete(
      DatabaseHelper.tableSchedule,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取所有日程
  Future<List<ScheduleModel>> getAllSchedules({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSchedule,
      limit: limit,
      offset: offset,
      orderBy: orderBy ?? 'start_time ${descending ? 'DESC' : 'ASC'}',
    );
    
    return List.generate(maps.length, (i) {
      return ScheduleModel.fromMap(maps[i]);
    });
  }

  // 获取指定日期范围内的日程
  Future<List<ScheduleModel>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeAllDay = true,
    String? category,
    bool? isRepeated,
  }) async {
    final db = await _databaseHelper.database;
    
    // 构建WHERE子句和参数
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];
    
    // 日期范围条件：结束时间 >= 开始日期 AND 开始时间 <= 结束日期
    whereConditions.add('end_time >= ? AND start_time <= ?');
    whereArgs.add(startDate.millisecondsSinceEpoch);
    whereArgs.add(endDate.millisecondsSinceEpoch);
    
    if (!includeAllDay) {
      whereConditions.add('is_all_day = 0');
    }
    
    if (category != null) {
      whereConditions.add('category = ?');
      whereArgs.add(category);
    }
    
    if (isRepeated != null) {
      whereConditions.add('is_repeated = ?');
      whereArgs.add(isRepeated ? 1 : 0);
    }
    
    final String whereClause = whereConditions.join(' AND ');
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSchedule,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'start_time ASC',
    );
    
    return List.generate(maps.length, (i) {
      return ScheduleModel.fromMap(maps[i]);
    });
  }

  // 获取指定日期的日程
  Future<List<ScheduleModel>> getSchedulesByDate(
    DateTime date, {
    bool includeAllDay = true,
    String? category,
  }) async {
    // 设置日期的开始时间（00:00:00）和结束时间（23:59:59）
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return getSchedulesByDateRange(
      startOfDay,
      endOfDay,
      includeAllDay: includeAllDay,
      category: category,
    );
  }

  // 搜索日程（根据标题或描述）
  Future<List<ScheduleModel>> searchSchedules(String query) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSchedule,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'start_time ASC',
    );
    
    return List.generate(maps.length, (i) {
      return ScheduleModel.fromMap(maps[i]);
    });
  }

  // 根据分类获取日程
  Future<List<ScheduleModel>> getSchedulesByCategory(String category) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSchedule,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'start_time ASC',
    );
    
    return List.generate(maps.length, (i) {
      return ScheduleModel.fromMap(maps[i]);
    });
  }

  // 获取今日日程
  Future<List<ScheduleModel>> getTodaySchedules({
    bool includeAllDay = true,
    String? category,
  }) async {
    return getSchedulesByDate(
      DateTime.now(),
      includeAllDay: includeAllDay,
      category: category,
    );
  }

  // 获取未来日程
  Future<List<ScheduleModel>> getUpcomingSchedules({
    int limit = 10,
    String? category,
  }) async {
    final db = await _databaseHelper.database;
    
    final DateTime now = DateTime.now();
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSchedule,
      where: category != null 
          ? 'start_time >= ? AND category = ?' 
          : 'start_time >= ?',
      whereArgs: category != null 
          ? [now.millisecondsSinceEpoch, category] 
          : [now.millisecondsSinceEpoch],
      orderBy: 'start_time ASC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return ScheduleModel.fromMap(maps[i]);
    });
  }
} 