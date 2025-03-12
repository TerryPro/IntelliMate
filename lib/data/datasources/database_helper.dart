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


    try {
      // 打开数据库，如果不存在则创建
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      
      return db;
    } catch (e) {
      rethrow;
    }
  }

  // 确保数据库已初始化并包含所有表
  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    
    try {
      final db = await database;
      
      // 检查表是否存在
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      
      // 检查特定表是否存在
      bool hasNoteTable = tableNames.contains(tableNote);
      if (!hasNoteTable) {
        await _createNoteTable(db);
      } else {
      }
      
      bool hasTaskTable = tableNames.contains(tableTask);
      if (!hasTaskTable) {
        await _createTaskTable(db);
      } else {
      }
      
      bool hasDailyNoteTable = tableNames.contains(tableDailyNote);
      if (!hasDailyNoteTable) {
        await _createDailyNoteTable(db);
      } else {
      }
      
      bool hasScheduleTable = tableNames.contains(tableSchedule);
      if (!hasScheduleTable) {
        await _createScheduleTable(db);
      } else {
      }
      
      bool hasMemoTable = tableNames.contains(tableMemo);
      if (!hasMemoTable) {
        await _createMemoTable(db);
      } else {
      }
      
      bool hasFinanceTable = tableNames.contains(tableFinance);
      if (!hasFinanceTable) {
        await _createFinanceTable(db);
      } else {
      }
      
      _initialized = true;
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }

  // 创建备忘表
  Future<void> _createMemoTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableMemo (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          date INTEGER NOT NULL,
          category TEXT,
          priority TEXT NOT NULL,
          is_pinned INTEGER NOT NULL DEFAULT 0,
          is_completed INTEGER NOT NULL DEFAULT 0,
          completed_at INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
    } catch (e) {
      rethrow;
    }
  }

  // 创建财务表
  Future<void> _createFinanceTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableFinance (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          description TEXT,
          date INTEGER NOT NULL,
          payment_method TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
    } catch (e) {
      rethrow;
    }
  }

  // 数据库创建回调
  Future<void> _onCreate(Database db, int version) async {
    await _createNoteTable(db);
    await _createTaskTable(db);
    await _createDailyNoteTable(db);
    await _createScheduleTable(db);
    await _createMemoTable(db);
    await _createFinanceTable(db);
    // 创建其他表...
  }

  // 数据库升级回调
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 处理数据库升级逻辑
  }

  // 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}