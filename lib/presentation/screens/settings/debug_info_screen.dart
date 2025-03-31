import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:intellimate/presentation/screens/settings/table_detail_screen.dart';

class DebugInfoScreen extends StatefulWidget {
  const DebugInfoScreen({super.key});

  @override
  State<DebugInfoScreen> createState() => _DebugInfoScreenState();
}

class _DebugInfoScreenState extends State<DebugInfoScreen> {
  String _databasePath = '';
  List<Map<String, dynamic>> _tableInfo = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取数据库路径
      final databasesPath = await getDatabasesPath();
      final pathStr = path.join(databasesPath, DatabaseHelper.databaseName);

      // 获取数据库表信息
      final db = await DatabaseHelper.instance.database;
      final tables = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

      setState(() {
        _databasePath = pathStr;
        _tableInfo = tables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('加载数据库信息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 自定义顶部导航栏
          _buildCustomAppBar(),

          // 主体内容
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 数据库路径信息卡片
                          _buildInfoCard(
                            title: '数据库路径',
                            content: _databasePath,
                            icon: Icons.folder,
                          ),

                          const SizedBox(height: 16),

                          // 数据库表信息卡片
                          _buildTableInfoCard(),
                          
                          const SizedBox(height: 16),
                          
                          // 添加新表按钮
                          _buildAddNewTableButton(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 构建自定义顶部导航栏
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(this.context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(this.context, AppRoutes.home);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.whiteWithOpacity20,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '调试信息',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 构建信息卡片
  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建表信息卡片
  Widget _buildTableInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.table_chart,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const Text(
                '数据库表信息',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _tableInfo.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                this.context,
                                MaterialPageRoute(
                                  builder: (context) => TableDetailScreen(
                                      tableName: _tableInfo[i]['name'].toString()),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  _tableInfo[i]['name'].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 清空表按钮
                        IconButton(
                          icon: const Icon(Icons.cleaning_services, size: 18, color: Colors.blue),
                          tooltip: '清空表',
                          onPressed: () {
                            _showConfirmDialog(
                              context: context,
                              title: '清空表',
                              content: '确定要清空表 ${_tableInfo[i]['name']} 中的所有数据吗？此操作不可恢复。',
                              onConfirm: () async {
                                await _clearTable(_tableInfo[i]['name'].toString());
                              },
                            );
                          },
                        ),
                        // 删除表按钮
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          tooltip: '删除表',
                          onPressed: () {
                            _showConfirmDialog(
                              context: context,
                              title: '删除表',
                              content: '确定要删除表 ${_tableInfo[i]['name']} 吗？此操作不可恢复。',
                              onConfirm: () async {
                                await _dropTable(_tableInfo[i]['name'].toString());
                              },
                            );
                          },
                        ),
                        // 创建表按钮
                        IconButton(
                          icon: const Icon(Icons.add_box, size: 18, color: Colors.green),
                          tooltip: '创建表',
                          onPressed: () {
                            _showConfirmDialog(
                              context: context,
                              title: '创建表',
                              content: '确定要重新创建表 ${_tableInfo[i]['name']} 吗？如果表已存在，此操作将失败。',
                              onConfirm: () async {
                                await _createTable(_tableInfo[i]['name'].toString());
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 显示确认对话框
  Future<void> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required Function onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  // 清空表中的数据
  Future<void> _clearTable(String tableName) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(tableName);
      
      // 刷新数据
      await _loadDatabaseInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('表 $tableName 已清空')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清空表失败: $e')),
        );
      }
      debugPrint('清空表失败: $e');
    }
  }

  // 删除表
  Future<void> _dropTable(String tableName) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.execute('DROP TABLE IF EXISTS $tableName');
      
      // 刷新数据
      await _loadDatabaseInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('表 $tableName 已删除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除表失败: $e')),
        );
      }
      debugPrint('删除表失败: $e');
    }
  }

  // 创建表
  Future<void> _createTable(String tableName) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // 使用SQL语句直接创建表
      switch (tableName) {
        case DatabaseHelper.tableUser:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tableUser} (
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
          break;
        case DatabaseHelper.tableNote:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tableNote} (
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
          break;
        case DatabaseHelper.tableTask:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tableTask} (
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
          break;
        case DatabaseHelper.tableDailyNote:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tableDailyNote} (
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
          break;
        case DatabaseHelper.tableSchedule:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tableSchedule} (
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
          break;
        case DatabaseHelper.tableMemo:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tableMemo} (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              content TEXT,
              category TEXT,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
          break;
        case DatabaseHelper.tableFinance:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tableFinance} (
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
          break;
        case DatabaseHelper.tableGoal:
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${DatabaseHelper.tableGoal} (
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
          break;
        case DatabaseHelper.tableTravel:
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${DatabaseHelper.tableTravel} (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              start_date TEXT NOT NULL,
              end_date TEXT NOT NULL,
              destination TEXT NOT NULL,
              places TEXT NOT NULL,
              people_count INTEGER NOT NULL,
              budget REAL NOT NULL,
              actual_cost REAL,
              status INTEGER NOT NULL,
              photo_count INTEGER,
              tasks TEXT,
              notes TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          break;
        case DatabaseHelper.tablePhoto:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tablePhoto} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              path TEXT NOT NULL,
              name TEXT,
              description TEXT,
              date_created INTEGER NOT NULL,
              date_modified INTEGER NOT NULL,
              is_favorite INTEGER NOT NULL DEFAULT 0,
              album_id TEXT,
              size INTEGER NOT NULL,
              location TEXT,
              metadata TEXT
            )
          ''');
          break;
        case DatabaseHelper.tablePhotoAlbum:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tablePhotoAlbum} (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              cover_photo_path TEXT,
              date_created INTEGER NOT NULL,
              date_modified INTEGER NOT NULL,
              photo_count INTEGER DEFAULT 0,
              description TEXT
            )
          ''');
          break;
        case DatabaseHelper.tablePhotoAlbumMap:
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.tablePhotoAlbumMap} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              photo_id INTEGER NOT NULL,
              album_id TEXT NOT NULL,
              date_added INTEGER NOT NULL,
              FOREIGN KEY (photo_id) REFERENCES ${DatabaseHelper.tablePhoto} (id) ON DELETE CASCADE,
              FOREIGN KEY (album_id) REFERENCES ${DatabaseHelper.tablePhotoAlbum} (id) ON DELETE CASCADE
            )
          ''');
          break;
        default:
          throw Exception('未知的表名: $tableName');
      }
      
      // 刷新数据
      await _loadDatabaseInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('表 $tableName 已创建')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建表失败: $e')),
        );
      }
      debugPrint('创建表失败: $e');
    }
  }
  
  // 构建添加新表按钮
  Widget _buildAddNewTableButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const Text(
                '添加新表',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _showAddTableDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('添加新表'),
          ),
        ],
      ),
    );
  }
  
  // 显示添加表对话框
  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择要创建的表'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTableOption(DatabaseHelper.tableUser, '用户表'),
                _buildTableOption(DatabaseHelper.tableNote, '笔记表'),
                _buildTableOption(DatabaseHelper.tableTask, '任务表'),
                _buildTableOption(DatabaseHelper.tableDailyNote, '日常点滴表'),
                _buildTableOption(DatabaseHelper.tableSchedule, '日程表'),
                _buildTableOption(DatabaseHelper.tableMemo, '备忘表'),
                _buildTableOption(DatabaseHelper.tableFinance, '财务表'),
                _buildTableOption(DatabaseHelper.tableGoal, '目标表'),
                _buildTableOption(DatabaseHelper.tableTravel, '旅游表'),
                _buildTableOption(DatabaseHelper.tablePhoto, '照片表'),
                _buildTableOption(DatabaseHelper.tablePhotoAlbum, '相册表'),
                _buildTableOption(DatabaseHelper.tablePhotoAlbumMap, '照片-相册映射表'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }
  
  // 构建表选项
  Widget _buildTableOption(String tableName, String displayName) {
    return ListTile(
      title: Text(displayName),
      subtitle: Text(tableName),
      onTap: () {
        Navigator.of(context).pop();
        _showConfirmDialog(
          context: context,
          title: '创建表',
          content: '确定要创建表 $tableName 吗？',
          onConfirm: () async {
            await _createTable(tableName);
          },
        );
      },
    );
  }
}
