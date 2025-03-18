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
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableNote,
        limit: limit,
        offset: offset,
        orderBy: orderBy ?? 'created_at ${descending ? 'DESC' : 'ASC'}',
      );
      
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 根据ID获取笔记
  @override
  Future<NoteModel?> getNoteById(String id) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableNote,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }
      
      return NoteModel.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  /// 创建笔记
  @override
  Future<NoteModel> createNote(NoteModel note) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    // 生成新ID
    final String id = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final NoteModel newNote = note.copyWith(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    
    try {
      
      await db.insert(
        DatabaseHelper.tableNote,
        newNote.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      
      // 验证笔记是否真的保存了
      final verifyResult = await db.query(
        DatabaseHelper.tableNote,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (verifyResult.isNotEmpty) {
      } else {
      }
      
      return newNote;
    } catch (e) {
      rethrow;
    }
  }

  /// 更新笔记
  @override
  Future<int> updateNote(NoteModel note) async {
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
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// 删除笔记
  @override
  Future<int> deleteNote(String id) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final result = await db.delete(
        DatabaseHelper.tableNote,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// 搜索笔记
  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    await _ensureDatabaseReady();
    final db = await _databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableNote,
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 获取收藏的笔记
  @override
  Future<List<NoteModel>> getFavoriteNotes() async {
    return getNotesByCondition(isFavorite: true);
  }

  /// 根据分类获取笔记
  @override
  Future<List<NoteModel>> getNotesByCategory(String category) async {
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
      
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }
} 