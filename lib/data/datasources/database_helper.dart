import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' show Platform;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  static Database? _database;
  static bool _initialized = false;

  // 数据库版本
  static const int _databaseVersion = 1;
  // 数据库名称
  static const String _databaseName = 'intellimate.db';

  // 表名
  static const String tableUser = 'users';
  static const String tableGoal = 'goals';
  static const String tableDailyNote = 'daily_notes';
  static const String tableNote = 'notes';
  static const String tableSchedule = 'schedules';
  static const String tableTask = 'tasks';
  static const String tableFinance = 'finances';
  static const String tableMemo = 'memos';
  static const String tableTravel = 'travels';

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    print('初始化数据库: $path');
    print('当前平台: ${Platform.operatingSystem}');

    try {
      // 打开数据库，如果不存在则创建
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      
      print('数据库初始化成功');
      return db;
    } catch (e) {
      print('数据库初始化失败: $e');
      rethrow;
    }
  }

  // 确保数据库已初始化并包含所有表
  Future<void> ensureInitialized() async {
    if (_initialized) {
      print('数据库已经初始化过，跳过');
      return;
    }
    
    try {
      final db = await database;
      print('检查数据库是否包含所有表');
      
      // 检查表是否存在
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      print('数据库中的表: $tableNames');
      
      // 检查特定表是否存在
      bool hasNoteTable = tableNames.contains(tableNote);
      if (!hasNoteTable) {
        print('笔记表不存在，正在创建...');
        await _createNoteTable(db);
      } else {
        print('笔记表已存在');
      }
      
      bool hasTaskTable = tableNames.contains(tableTask);
      if (!hasTaskTable) {
        print('任务表不存在，正在创建...');
        await _createTaskTable(db);
      } else {
        print('任务表已存在');
      }
      
      bool hasDailyNoteTable = tableNames.contains(tableDailyNote);
      if (!hasDailyNoteTable) {
        print('日常点滴表不存在，正在创建...');
        await _createDailyNoteTable(db);
      } else {
        print('日常点滴表已存在');
      }
      
      bool hasScheduleTable = tableNames.contains(tableSchedule);
      if (!hasScheduleTable) {
        print('日程表不存在，正在创建...');
        await _createScheduleTable(db);
      } else {
        print('日程表已存在');
      }
      
      _initialized = true;
      print('数据库初始化完成');
    } catch (e) {
      print('确保数据库初始化时出错: $e');
      _initialized = false;
      rethrow;
    }
  }
  
  // 创建笔记表
  Future<void> _createNoteTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableNote (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          tags TEXT,
          category TEXT,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      print('笔记表创建成功');
    } catch (e) {
      print('创建笔记表失败: $e');
      rethrow;
    }
  }
  
  // 创建任务表
  Future<void> _createTaskTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableTask (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          due_date INTEGER,
          is_completed INTEGER NOT NULL DEFAULT 0,
          category TEXT,
          priority INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      print('任务表创建成功');
    } catch (e) {
      print('创建任务表失败: $e');
      rethrow;
    }
  }

  // 创建日常点滴表
  Future<void> _createDailyNoteTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableDailyNote (
          id TEXT PRIMARY KEY,
          author TEXT,
          content TEXT NOT NULL,
          images TEXT,
          location TEXT,
          mood TEXT,
          weather TEXT,
          is_private INTEGER NOT NULL DEFAULT 0,
          likes INTEGER NOT NULL DEFAULT 0,
          comments INTEGER NOT NULL DEFAULT 0,
          code_snippet TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      print('日常点滴表创建成功');
    } catch (e) {
      print('创建日常点滴表失败: $e');
      rethrow;
    }
  }

  // 创建日程表
  Future<void> _createScheduleTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableSchedule (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          start_time INTEGER NOT NULL,
          end_time INTEGER NOT NULL,
          location TEXT,
          is_all_day INTEGER NOT NULL DEFAULT 0,
          category TEXT,
          is_repeated INTEGER NOT NULL DEFAULT 0,
          repeat_type TEXT,
          participants TEXT,
          reminder TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      print('日程表创建成功');
    } catch (e) {
      print('创建日程表失败: $e');
      rethrow;
    }
  }

  // 数据库创建回调
  Future<void> _onCreate(Database db, int version) async {
    print('创建新数据库，版本: $version');
    await _createNoteTable(db);
    await _createTaskTable(db);
    await _createDailyNoteTable(db);
    await _createScheduleTable(db);
    // 创建其他表...
  }

  // 数据库升级回调
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('升级数据库，从版本 $oldVersion 到 $newVersion');
    // 处理数据库升级逻辑
  }

  // 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}