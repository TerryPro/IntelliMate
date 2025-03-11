import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/memo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class MemoDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 确保数据库表已经初始化
  Future<void> _ensureDatabaseInitialized() async {
    await _databaseHelper.ensureInitialized();
  }

  // 根据ID获取备忘
  Future<MemoModel?> getMemoById(String id) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return MemoModel.fromMap(maps.first);
  }

  // 创建备忘
  Future<MemoModel> createMemo(MemoModel memo) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final MemoModel newMemo = memo.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    await db.insert(
      DatabaseHelper.tableMemo,
      newMemo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return newMemo;
  }

  // 更新备忘
  Future<int> updateMemo(MemoModel memo) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    // 更新时间戳
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedMemo = memo.copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    return await db.update(
      DatabaseHelper.tableMemo,
      updatedMemo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  // 删除备忘
  Future<int> deleteMemo(String id) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    return await db.delete(
      DatabaseHelper.tableMemo,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取所有备忘
  Future<List<MemoModel>> getAllMemos({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      limit: limit,
      offset: offset,
      orderBy: orderBy ?? 'date ${descending ? 'DESC' : 'ASC'}',
    );
    
    return List.generate(maps.length, (i) {
      return MemoModel.fromMap(maps[i]);
    });
  }

  // 按日期获取备忘
  Future<List<MemoModel>> getMemosByDate(DateTime date) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    // 设置日期的开始时间（00:00:00）和结束时间（23:59:59）
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) {
      return MemoModel.fromMap(maps[i]);
    });
  }

  // 获取已完成的备忘
  Future<List<MemoModel>> getCompletedMemos() async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'completed_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return MemoModel.fromMap(maps[i]);
    });
  }

  // 获取未完成的备忘
  Future<List<MemoModel>> getUncompletedMemos() async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      where: 'is_completed = ?',
      whereArgs: [0],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) {
      return MemoModel.fromMap(maps[i]);
    });
  }

  // 按优先级获取备忘
  Future<List<MemoModel>> getMemosByPriority(String priority) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) {
      return MemoModel.fromMap(maps[i]);
    });
  }

  // 获取置顶备忘
  Future<List<MemoModel>> getPinnedMemos() async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      where: 'is_pinned = ?',
      whereArgs: [1],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) {
      return MemoModel.fromMap(maps[i]);
    });
  }

  // 搜索备忘
  Future<List<MemoModel>> searchMemos(String query) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return MemoModel.fromMap(maps[i]);
    });
  }

  // 按类别获取备忘
  Future<List<MemoModel>> getMemosByCategory(String category) async {
    await _ensureDatabaseInitialized();
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMemo,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) {
      return MemoModel.fromMap(maps[i]);
    });
  }
} 