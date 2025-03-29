import 'dart:io';
import 'dart:convert';
import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/utils/permission_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intellimate/utils/app_logger.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  static BackupService get instance => _instance;

  BackupService._internal();

  /// 获取应用公共目录的backup目录（公开方法）
  Future<Directory> getBackupDirectory() async {
    return await _getBackupDirectory();
  }

  /// 获取应用公共目录的backup目录
  Future<Directory> _getBackupDirectory() async {
    try {
      // 先请求存储权限
      final hasPermission = await PermissionHelper.requestStoragePermission();
      if (!hasPermission) {
        AppLogger.log('未获得存储权限，将使用应用内部存储作为备份目录');
        // 使用应用内部存储目录
        final appDir = await getApplicationDocumentsDirectory();
        final backupDir = Directory('${appDir.path}/backup');
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        AppLogger.log('使用内部存储作为备份目录: ${backupDir.path}');
        return backupDir;
      }
      
      try {
        // 尝试获取应用外部存储目录 - Android专用目录
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // 创建备份目录
          final backupDir = Directory('${externalDir.path}/backup');
          if (!await backupDir.exists()) {
            await backupDir.create(recursive: true);
          }
          AppLogger.log('使用外部存储目录作为备份目录: ${backupDir.path}');
          return backupDir;
        } else {
          throw Exception('无法获取外部存储目录');
        }
      } catch (e) {
        AppLogger.log('获取外部存储目录失败: $e');
        // 回退到应用文档目录
        final appDir = await getApplicationDocumentsDirectory();
        final backupDir = Directory('${appDir.path}/backup');
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        AppLogger.log('使用内部存储作为备份目录: ${backupDir.path}');
        return backupDir;
      }
    } catch (e) {
      AppLogger.log('获取备份目录出错: $e');
      // 出错时使用应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/backup');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      AppLogger.log('因出错使用内部存储作为备份目录: ${backupDir.path}');
      return backupDir;
    }
  }

  /// 备份数据库到backup目录
  Future<String> backupDatabase() async {
    try {
      // 获取源数据库路径
      final dbPath = await getDatabasesPath();
      final sourcePath = join(dbPath, DatabaseHelper.databaseName);
      
      // 获取备份目录
      final backupDir = await _getBackupDirectory();
      
      // 创建带时间戳的备份文件名
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFileName = 'intellimate_$timestamp.db';
      final backupPath = join(backupDir.path, backupFileName);
      
      // 复制数据库文件
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(backupPath);
        return backupPath;
      } else {
        throw Exception('数据库文件不存在');
      }
    } catch (e) {
      AppLogger.log('备份数据库出错: $e');
      rethrow;
    }
  }

  /// 获取所有备份文件
  Future<List<FileSystemEntity>> getAllBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      final List<FileSystemEntity> files = await backupDir.list().toList();
      
      // 过滤出数据库备份文件并按修改时间排序（最新的在前）
      final backupFiles = files.where((file) => 
        file.path.endsWith('.db') && 
        file is File
      ).toList();
      
      backupFiles.sort((a, b) {
        return File(b.path).lastModifiedSync().compareTo(
          File(a.path).lastModifiedSync());
      });
      
      return backupFiles;
    } catch (e) {
      AppLogger.log('获取备份文件列表出错: $e');
      rethrow;
    }
  }

  /// 从备份文件恢复数据库
  Future<bool> restoreDatabase(String backupPath) async {
    try {
      // 先关闭当前数据库连接
      await DatabaseHelper.instance.close();
      
      // 获取目标数据库路径
      final dbPath = await getDatabasesPath();
      final targetPath = join(dbPath, DatabaseHelper.databaseName);
      
      // 复制备份文件到数据库位置
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.copy(targetPath);
        
        // 重置数据库初始化状态
        DatabaseHelper.resetInitializationState();
        
        return true;
      } else {
        throw Exception('备份文件不存在');
      }
    } catch (e) {
      AppLogger.log('恢复数据库出错: $e');
      rethrow;
    }
  }

  /// 导出数据到JSON文件
  Future<String> exportDataToJson() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final Map<String, dynamic> allData = {};
      
      // 获取所有表名
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      // 遍历每个表并导出数据
      for (final tableName in tableNames) {
        final tableData = await db.query(tableName);
        // 将每条记录转换为Map
        final List<Map<String, dynamic>> tableRows = [];
        for (final row in tableData) {
          tableRows.add(Map<String, dynamic>.from(row));
        }
        allData[tableName] = tableRows;
      }
      
      // 获取导出目录
      final exportDir = await _getBackupDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportPath = join(exportDir.path, 'intellimate_export_$timestamp.json');
      
      // 将数据写入文件，使用jsonEncode确保正确的JSON格式
      final exportFile = File(exportPath);
      await exportFile.writeAsString(jsonEncode(allData));
      
      AppLogger.log('数据已导出到: $exportPath');
      return exportPath;
    } catch (e) {
      AppLogger.log('导出数据出错: $e');
      rethrow;
    }
  }

  /// 从JSON文件导入数据
  Future<bool> importDataFromJson(String jsonFilePath) async {
    try {
      // 读取JSON文件
      final jsonFile = File(jsonFilePath);
      if (!await jsonFile.exists()) {
        throw Exception('导入文件不存在');
      }
      
      // 解析JSON内容
      final jsonContent = await jsonFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonContent);
      
      // 获取数据库并开始事务
      final db = await DatabaseHelper.instance.database;
      await db.transaction((txn) async {
        // 遍历每个表
        for (final String tableName in data.keys) {
          // 检查表是否存在
          final tableExists = await _tableExists(txn, tableName);
          if (!tableExists) {
            AppLogger.log('警告: 表 $tableName 不存在，跳过导入');
            continue;
          }
          
          // 清空表
          await txn.delete(tableName);
          
          // 导入数据
          final List<dynamic> tableData = data[tableName];
          for (final dynamic row in tableData) {
            if (row is Map<String, dynamic>) {
              await txn.insert(tableName, row);
            }
          }
          
          AppLogger.log('已导入表 $tableName 的 ${tableData.length} 条记录');
        }
      });
      
      // 重置数据库初始化状态，确保下次使用时重新加载
      DatabaseHelper.resetInitializationState();
      
      AppLogger.log('数据导入成功');
      return true;
    } catch (e) {
      AppLogger.log('导入数据出错: $e');
      rethrow;
    }
  }
  
  /// 检查表是否存在
  Future<bool> _tableExists(Transaction txn, String tableName) async {
    final result = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name=?", [tableName]);
    return result.isNotEmpty;
  }
  
  /// 分享备份文件
  Future<void> shareBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // 使用新版的share_plus API
        final result = await Share.shareXFiles([XFile(filePath)], subject: '分享IntelliMate备份文件');
        AppLogger.log('分享结果: $result');
      } else {
        throw Exception('要分享的文件不存在');
      }
    } catch (e) {
      AppLogger.log('分享备份文件出错: $e');
      rethrow;
    }
  }
  
  /// 从备份目录导入所有数据库备份文件
  Future<List<String>> importBackupFilesFromDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        throw Exception('指定的目录不存在');
      }
      
      // 获取备份目录
      final backupDir = await _getBackupDirectory();
      
      // 获取目录中的所有.db文件
      final files = await directory
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .toList();
      
      // 导入文件到备份目录
      final List<String> importedFiles = [];
      for (final file in files) {
        final fileName = basename(file.path);
        final targetPath = join(backupDir.path, fileName);
        
        // 复制文件到备份目录
        await (file as File).copy(targetPath);
        importedFiles.add(targetPath);
      }
      
      return importedFiles;
    } catch (e) {
      AppLogger.log('导入备份文件出错: $e');
      rethrow;
    }
  }
  
  /// 删除备份文件
  Future<bool> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.log('删除备份文件出错: $e');
      rethrow;
    }
  }
} 