import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class NoteDataSource {
  /// 获取所有笔记
  Future<List<NoteModel>> getAllNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });

  /// 根据ID获取笔记
  Future<NoteModel?> getNoteById(String id);

  /// 创建笔记
  Future<NoteModel> createNote(NoteModel note);

  /// 更新笔记
  /// 返回受影响的行数
  Future<int> updateNote(NoteModel note);

  /// 删除笔记
  /// 返回受影响的行数
  Future<int> deleteNote(String id);

  /// 搜索笔记
  Future<List<NoteModel>> searchNotes(String query);

  /// 获取收藏的笔记
  Future<List<NoteModel>> getFavoriteNotes();

  /// 根据分类获取笔记
  Future<List<NoteModel>> getNotesByCategory(String category);

  /// 根据条件获取笔记
  Future<List<NoteModel>> getNotesByCondition({
    String? category,
    bool? isFavorite,
    List<String>? tags,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
}

class NoteDataSourceImpl extends NoteDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 确保数据库已初始化
  Future<void> _ensureDatabaseReady() async {
    await _databaseHelper.ensureInitialized();
  }

  /// 获取所有笔记
  @override
  Future<List<NoteModel>> getAllNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    print('NoteDataSourceImpl: 获取所有笔记');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableNote,
        limit: limit,
        offset: offset,
        orderBy: orderBy ?? 'created_at ${descending ? 'DESC' : 'ASC'}',
      );
      
      print('NoteDataSourceImpl: 查询成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('NoteDataSourceImpl: 查询失败: $e');
      rethrow;
    }
  }

  /// 根据ID获取笔记
  @override
  Future<NoteModel?> getNoteById(String id) async {
    print('NoteDataSourceImpl: 获取笔记，ID: $id');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableNote,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        print('NoteDataSourceImpl: 未找到笔记，ID: $id');
        return null;
      }
      
      print('NoteDataSourceImpl: 找到笔记，ID: $id');
      return NoteModel.fromMap(maps.first);
    } catch (e) {
      print('NoteDataSourceImpl: 获取笔记失败: $e');
      rethrow;
    }
  }

  /// 创建笔记
  @override
  Future<NoteModel> createNote(NoteModel note) async {
    print('NoteDataSource: 开始创建笔记');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    print('NoteDataSource: 数据库连接成功');
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    print('NoteDataSource: 生成ID $id 和时间戳 $timestamp');
    
    final NoteModel newNote = note.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    print('NoteDataSource: 创建新笔记对象: ${newNote.title}');
    
    try {
      print('NoteDataSource: 准备插入数据库，表名: ${DatabaseHelper.tableNote}');
      print('NoteDataSource: 数据内容: ${newNote.toMap()}');
      
      final result = await db.insert(
        DatabaseHelper.tableNote,
        newNote.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('NoteDataSource: 数据库插入成功，结果: $result');
      
      // 验证笔记是否真的保存了
      final verifyResult = await db.query(
        DatabaseHelper.tableNote,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('NoteDataSource: 验证结果 - 找到 ${verifyResult.length} 条记录');
      if (verifyResult.isNotEmpty) {
        print('NoteDataSource: 验证成功 - 找到匹配记录');
      } else {
        print('NoteDataSource: 验证失败 - 未找到匹配记录！');
      }
      
      return newNote;
    } catch (e) {
      print('NoteDataSource: 插入失败: $e');
      rethrow;
    }
  }

  /// 更新笔记
  @override
  Future<int> updateNote(NoteModel note) async {
    print('NoteDataSourceImpl: 更新笔记，ID: ${note.id}');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    // 更新时间戳
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedNote = note.copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    try {
      final result = await db.update(
        DatabaseHelper.tableNote,
        updatedNote.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      
      print('NoteDataSourceImpl: 更新笔记成功，受影响行数: $result');
      return result;
    } catch (e) {
      print('NoteDataSourceImpl: 更新笔记失败: $e');
      rethrow;
    }
  }

  /// 删除笔记
  @override
  Future<int> deleteNote(String id) async {
    print('NoteDataSourceImpl: 删除笔记，ID: $id');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final result = await db.delete(
        DatabaseHelper.tableNote,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('NoteDataSourceImpl: 删除笔记成功，受影响行数: $result');
      return result;
    } catch (e) {
      print('NoteDataSourceImpl: 删除笔记失败: $e');
      rethrow;
    }
  }

  /// 搜索笔记
  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    print('NoteDataSourceImpl: 搜索笔记，关键词: $query');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableNote,
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      
      print('NoteDataSourceImpl: 搜索成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('NoteDataSourceImpl: 搜索失败: $e');
      rethrow;
    }
  }

  /// 获取收藏的笔记
  @override
  Future<List<NoteModel>> getFavoriteNotes() async {
    print('NoteDataSourceImpl: 获取收藏笔记');
    return getNotesByCondition(isFavorite: true);
  }

  /// 根据分类获取笔记
  @override
  Future<List<NoteModel>> getNotesByCategory(String category) async {
    print('NoteDataSourceImpl: 获取分类笔记，分类: $category');
    return getNotesByCondition(category: category);
  }

  /// 根据条件获取笔记
  @override
  Future<List<NoteModel>> getNotesByCondition({
    String? category,
    bool? isFavorite,
    List<String>? tags,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    print('NoteDataSourceImpl: 根据条件获取笔记');
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    // 构建WHERE子句和参数
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];
    
    if (category != null) {
      whereConditions.add('category = ?');
      whereArgs.add(category);
    }
    
    if (isFavorite != null) {
      whereConditions.add('is_favorite = ?');
      whereArgs.add(isFavorite ? 1 : 0);
    }
    
    if (tags != null && tags.isNotEmpty) {
      // 搜索包含任何一个标签的笔记
      final List<String> tagConditions = tags.map((tag) => "tags LIKE ?").toList();
      whereConditions.add('(${tagConditions.join(' OR ')})');
      whereArgs.addAll(tags.map((tag) => '%$tag%').toList());
    }
    
    if (fromDate != null) {
      whereConditions.add('created_at >= ?');
      whereArgs.add(fromDate.millisecondsSinceEpoch);
    }
    
    if (toDate != null) {
      whereConditions.add('created_at <= ?');
      whereArgs.add(toDate.millisecondsSinceEpoch);
    }
    
    final String? whereClause = whereConditions.isNotEmpty 
        ? whereConditions.join(' AND ') 
        : null;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableNote,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: limit,
        offset: offset,
        orderBy: orderBy ?? 'created_at ${descending ? 'DESC' : 'ASC'}',
      );
      
      print('NoteDataSourceImpl: 条件查询成功，获取到 ${maps.length} 条记录');
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('NoteDataSourceImpl: 条件查询失败: $e');
      rethrow;
    }
  }
} 