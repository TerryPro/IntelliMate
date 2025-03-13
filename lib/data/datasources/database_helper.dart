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
      
      // 检查用户表是否存在
      bool hasUserTable = tableNames.contains(tableUser);
      if (!hasUserTable) {
        await _createUserTable(db);
        print('创建用户表成功');
      } else {
        print('用户表已存在');
        
        // 验证用户表结构
        await _verifyUserTableStructure(db);
      }
      
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
      
      bool hasGoalTable = tableNames.contains(tableGoal);
      if (!hasGoalTable) {
        await _createGoalTable(db);
        print('创建目标表成功');
      } else {
        print('目标表已存在');
      }
      
      _initialized = true;
      print('数据库初始化完成，所有表已检查并创建');
    } catch (e) {
      _initialized = false;
      print('数据库初始化失败: $e');
      rethrow;
    }
  }
  
  // 创建用户表
  Future<void> _createUserTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableUser (
          id TEXT PRIMARY KEY,
          username TEXT NOT NULL,
          nickname TEXT,
          avatar TEXT,
          email TEXT,
          phone TEXT,
          gender TEXT,
          birthday TEXT,
          signature TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      print('用户表创建SQL执行成功');
    } catch (e) {
      print('创建用户表失败: $e');
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

  // 创建目标表
  Future<void> _createGoalTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableGoal (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        progress REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL,
        category TEXT,
        milestones TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    print('目标表创建成功');
  }

  // 数据库创建回调
  Future<void> _onCreate(Database db, int version) async {
    try {
      print('正在创建数据库表...');
      await _createUserTable(db);  // 首先创建用户表
      await _createNoteTable(db);
      await _createTaskTable(db);
      await _createDailyNoteTable(db);
      await _createScheduleTable(db);
      await _createMemoTable(db);
      await _createFinanceTable(db);
      await _createGoalTable(db);  // 添加创建目标表
      print('所有数据库表创建完成');
    } catch (e) {
      print('数据库表创建失败: $e');
      rethrow;
    }
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

  // 验证用户表结构并修复
  Future<void> _verifyUserTableStructure(Database db) async {
    try {
      // 获取用户表信息
      final tableInfo = await db.rawQuery("PRAGMA table_info($tableUser)");
      print('用户表结构: $tableInfo');
      
      // 检查时间戳字段类型
      bool needsRebuild = false;
      final createdAtColumn = tableInfo.firstWhere((col) => col['name'] == 'created_at', orElse: () => {});
      final updatedAtColumn = tableInfo.firstWhere((col) => col['name'] == 'updated_at', orElse: () => {});
      
      if (createdAtColumn.isEmpty || updatedAtColumn.isEmpty) {
        print('用户表缺少时间戳字段，需要重建');
        needsRebuild = true;
      } else {
        // 检查字段类型
        final createdAtType = createdAtColumn['type']?.toString().toUpperCase() ?? '';
        final updatedAtType = updatedAtColumn['type']?.toString().toUpperCase() ?? '';
        
        print('时间戳字段类型 - created_at: $createdAtType, updated_at: $updatedAtType');
        
        if (createdAtType != 'INTEGER' || updatedAtType != 'INTEGER') {
          print('时间戳字段类型不是INTEGER，需要重建表');
          needsRebuild = true;
        }
      }
      
      if (needsRebuild) {
        await _rebuildUserTable(db);
      }
    } catch (e) {
      print('验证用户表结构失败: $e');
    }
  }
  
  // 重建用户表
  Future<void> _rebuildUserTable(Database db) async {
    print('开始重建用户表...');
    
    try {
      // 开始事务
      await db.transaction((txn) async {
        // 1. 备份现有数据
        print('备份现有用户数据');
        final existingData = await txn.query(tableUser);
        print('找到 ${existingData.length} 条用户记录');
        
        // 2. 重命名现有表
        print('重命名现有用户表');
        await txn.execute('ALTER TABLE $tableUser RENAME TO ${tableUser}_old');
        
        // 3. 创建新表
        print('创建新用户表');
        await txn.execute('''
          CREATE TABLE $tableUser (
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            nickname TEXT,
            avatar TEXT,
            email TEXT,
            phone TEXT,
            gender TEXT,
            birthday TEXT,
            signature TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        
        // 4. 迁移数据
        print('迁移用户数据');
        for (var record in existingData) {
          // 处理时间戳字段
          var createdAt = record['created_at'];
          var updatedAt = record['updated_at'];
          
          // 如果是字符串，尝试转换为毫秒时间戳
          if (createdAt is String) {
            try {
              createdAt = int.tryParse(createdAt) ?? DateTime.now().millisecondsSinceEpoch;
            } catch (_) {
              createdAt = DateTime.now().millisecondsSinceEpoch;
            }
          } else createdAt ??= DateTime.now().millisecondsSinceEpoch;
          
          if (updatedAt is String) {
            try {
              updatedAt = int.tryParse(updatedAt) ?? DateTime.now().millisecondsSinceEpoch;
            } catch (_) {
              updatedAt = DateTime.now().millisecondsSinceEpoch;
            }
          } else updatedAt ??= DateTime.now().millisecondsSinceEpoch;
          
          // 创建新记录
          final newRecord = {
            'id': record['id'],
            'username': record['username'],
            'nickname': record['nickname'],
            'avatar': record['avatar'],
            'email': record['email'],
            'phone': record['phone'],
            'gender': record['gender'],
            'birthday': record['birthday'],
            'signature': record['signature'],
            'created_at': createdAt,
            'updated_at': updatedAt,
          };
          
          print('迁移用户记录: $newRecord');
          await txn.insert(tableUser, newRecord);
        }
        
        // 5. 删除旧表
        print('删除旧用户表');
        await txn.execute('DROP TABLE IF EXISTS ${tableUser}_old');
        
        print('用户表重建完成');
      });
    } catch (e) {
      print('重建用户表失败: $e');
      print('堆栈跟踪: ${StackTrace.current}');
      rethrow;
    }
  }
}