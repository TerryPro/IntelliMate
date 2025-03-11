import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/daily_note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class DailyNoteDataSource {
  /// 获取所有日常点滴
  Future<List<DailyNoteModel>> getAllDailyNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });

  /// 根据ID获取日常点滴
  Future<DailyNoteModel?> getDailyNoteById(String id);

  /// 创建日常点滴
  Future<DailyNoteModel> createDailyNote(DailyNoteModel dailyNote);

  /// 更新日常点滴
  /// 返回受影响的行数
  Future<int> updateDailyNote(DailyNoteModel dailyNote);

  /// 删除日常点滴
  /// 返回受影响的行数
  Future<int> deleteDailyNote(String id);

  /// 搜索日常点滴
  Future<List<DailyNoteModel>> searchDailyNotes(String query);

  /// 获取私密日常点滴
  Future<List<DailyNoteModel>> getPrivateDailyNotes();

  /// 获取包含代码片段的日常点滴
  Future<List<DailyNoteModel>> getDailyNotesWithCodeSnippets();

  /// 根据条件获取日常点滴
  Future<List<DailyNoteModel>> getDailyNotesByCondition({
    String? mood,
    String? weather,
    bool? isPrivate,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
}

class DailyNoteDataSourceImpl implements DailyNoteDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 确保数据库已初始化
  Future<void> _ensureDatabaseReady() async {
    await _databaseHelper.ensureInitialized();
  }

  /// 获取所有日常点滴
  @override
  Future<List<DailyNoteModel>> getAllDailyNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    print('DailyNoteDataSourceImpl: 获取所有日常点滴');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableDailyNote,
        limit: limit,
        offset: offset,
        orderBy: orderBy ?? 'created_at ${descending ? 'DESC' : 'ASC'}',
      );
      
      print('DailyNoteDataSourceImpl: 查询成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return DailyNoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('DailyNoteDataSourceImpl: 查询失败: $e');
      rethrow;
    }
  }

  /// 根据ID获取日常点滴
  @override
  Future<DailyNoteModel?> getDailyNoteById(String id) async {
    print('DailyNoteDataSourceImpl: 获取日常点滴，ID: $id');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableDailyNote,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        print('DailyNoteDataSourceImpl: 未找到日常点滴，ID: $id');
        return null;
      }
      
      print('DailyNoteDataSourceImpl: 找到日常点滴，ID: $id');
      return DailyNoteModel.fromMap(maps.first);
    } catch (e) {
      print('DailyNoteDataSourceImpl: 获取日常点滴失败: $e');
      rethrow;
    }
  }

  /// 创建日常点滴
  @override
  Future<DailyNoteModel> createDailyNote(DailyNoteModel dailyNote) async {
    print('DailyNoteDataSourceImpl: 开始创建日常点滴');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    print('DailyNoteDataSourceImpl: 数据库连接成功');
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    print('DailyNoteDataSourceImpl: 生成ID $id 和时间戳 $timestamp');
    
    final DailyNoteModel newDailyNote = dailyNote.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    print('DailyNoteDataSourceImpl: 创建新日常点滴对象');
    
    try {
      print('DailyNoteDataSourceImpl: 准备插入数据库，表名: ${DatabaseHelper.tableDailyNote}');
      print('DailyNoteDataSourceImpl: 数据内容: ${newDailyNote.toMap()}');
      
      final result = await db.insert(
        DatabaseHelper.tableDailyNote,
        newDailyNote.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('DailyNoteDataSourceImpl: 数据库插入成功，结果: $result');
      
      // 验证日常点滴是否真的保存了
      final verifyResult = await db.query(
        DatabaseHelper.tableDailyNote,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('DailyNoteDataSourceImpl: 验证结果 - 找到 ${verifyResult.length} 条记录');
      if (verifyResult.isNotEmpty) {
        print('DailyNoteDataSourceImpl: 验证成功 - 找到匹配记录');
      } else {
        print('DailyNoteDataSourceImpl: 验证失败 - 未找到匹配记录！');
      }
      
      return newDailyNote;
    } catch (e) {
      print('DailyNoteDataSourceImpl: 插入失败: $e');
      rethrow;
    }
  }

  /// 更新日常点滴
  @override
  Future<int> updateDailyNote(DailyNoteModel dailyNote) async {
    print('DailyNoteDataSourceImpl: 更新日常点滴，ID: ${dailyNote.id}');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    // 更新时间戳
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedDailyNote = dailyNote.copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    try {
      final result = await db.update(
        DatabaseHelper.tableDailyNote,
        updatedDailyNote.toMap(),
        where: 'id = ?',
        whereArgs: [dailyNote.id],
      );
      
      print('DailyNoteDataSourceImpl: 更新日常点滴成功，受影响行数: $result');
      return result;
    } catch (e) {
      print('DailyNoteDataSourceImpl: 更新日常点滴失败: $e');
      rethrow;
    }
  }

  /// 删除日常点滴
  @override
  Future<int> deleteDailyNote(String id) async {
    print('DailyNoteDataSourceImpl: 删除日常点滴，ID: $id');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final result = await db.delete(
        DatabaseHelper.tableDailyNote,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('DailyNoteDataSourceImpl: 删除日常点滴成功，受影响行数: $result');
      return result;
    } catch (e) {
      print('DailyNoteDataSourceImpl: 删除日常点滴失败: $e');
      rethrow;
    }
  }

  /// 搜索日常点滴
  @override
  Future<List<DailyNoteModel>> searchDailyNotes(String query) async {
    print('DailyNoteDataSourceImpl: 搜索日常点滴，关键词: $query');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableDailyNote,
        where: 'content LIKE ? OR code_snippet LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      
      print('DailyNoteDataSourceImpl: 搜索成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return DailyNoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('DailyNoteDataSourceImpl: 搜索失败: $e');
      rethrow;
    }
  }

  /// 获取私密日常点滴
  @override
  Future<List<DailyNoteModel>> getPrivateDailyNotes() async {
    print('DailyNoteDataSourceImpl: 获取私密日常点滴');
    return getDailyNotesByCondition(isPrivate: true);
  }

  /// 获取包含代码片段的日常点滴
  @override
  Future<List<DailyNoteModel>> getDailyNotesWithCodeSnippets() async {
    print('DailyNoteDataSourceImpl: 获取包含代码片段的日常点滴');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableDailyNote,
        where: 'code_snippet IS NOT NULL AND code_snippet != ""',
        orderBy: 'created_at DESC',
      );
      
      print('DailyNoteDataSourceImpl: 查询成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return DailyNoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('DailyNoteDataSourceImpl: 查询失败: $e');
      rethrow;
    }
  }

  /// 根据条件获取日常点滴
  @override
  Future<List<DailyNoteModel>> getDailyNotesByCondition({
    String? mood,
    String? weather,
    bool? isPrivate,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    print('DailyNoteDataSourceImpl: 根据条件获取日常点滴');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    // 构建查询条件
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];
    
    if (mood != null) {
      whereConditions.add('mood = ?');
      whereArgs.add(mood);
    }
    
    if (weather != null) {
      whereConditions.add('weather = ?');
      whereArgs.add(weather);
    }
    
    if (isPrivate != null) {
      whereConditions.add('is_private = ?');
      whereArgs.add(isPrivate ? 1 : 0);
    }
    
    if (fromDate != null) {
      whereConditions.add('created_at >= ?');
      whereArgs.add(fromDate.millisecondsSinceEpoch);
    }
    
    if (toDate != null) {
      whereConditions.add('created_at <= ?');
      whereArgs.add(toDate.millisecondsSinceEpoch);
    }
    
    // 组合条件
    String whereClause = whereConditions.isEmpty 
        ? '' 
        : whereConditions.join(' AND ');
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableDailyNote,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        limit: limit,
        offset: offset,
        orderBy: orderBy ?? 'created_at ${descending ? 'DESC' : 'ASC'}',
      );
      
      print('DailyNoteDataSourceImpl: 查询成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return DailyNoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('DailyNoteDataSourceImpl: 查询失败: $e');
      rethrow;
    }
  }
} 