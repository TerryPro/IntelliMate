import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/utils/backup_service.dart';
import 'package:intellimate/utils/permission_helper.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

class DataBackupScreen extends StatefulWidget {
  const DataBackupScreen({super.key});

  @override
  State<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends State<DataBackupScreen> {
  final BackupService _backupService = BackupService.instance;
  List<FileSystemEntity> _backupFiles = [];
  List<FileSystemEntity> _jsonBackupFiles = [];
  bool _isLoading = true;
  bool _isCreatingBackup = false;
  bool _isExportingJson = false;
  String? _errorMessage;
  bool _hasStoragePermission = false;
  String _activeTab = 'database'; // 'database' 或 'json'
  String _backupDirPath = ''; // 备份目录路径

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadBackups();
  }
  
  // 检查权限并加载备份
  Future<void> _checkPermissionAndLoadBackups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hasPermission = await PermissionHelper.requestStoragePermission();
      setState(() {
        _hasStoragePermission = hasPermission;
      });
      
      if (hasPermission) {
        // 获取备份目录路径
        final backupDir = await _backupService.getBackupDirectory();
        setState(() {
          _backupDirPath = backupDir.path;
        });
        
        await _loadBackups();
      } else {
        setState(() {
          _errorMessage = '未获得存储权限，无法访问备份文件';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '检查权限失败: $e';
        _isLoading = false;
      });
    }
  }

  // 加载备份文件列表
  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final backups = await _backupService.getAllBackups();
      // 获取JSON备份文件
      final backupDir = await _backupService.getBackupDirectory();
      final allFiles = await backupDir.list().toList();
      final jsonFiles = allFiles.where((file) => 
        file.path.endsWith('.json') && 
        file is File
      ).toList();
      
      jsonFiles.sort((a, b) {
        return File(b.path).lastModifiedSync().compareTo(
          File(a.path).lastModifiedSync());
      });
      
      setState(() {
        _backupFiles = backups;
        _jsonBackupFiles = jsonFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载备份文件失败: $e';
        _isLoading = false;
      });
    }
  }

  // 显示美化的Snackbar
  void _showSnackBar({
    required String message,
    bool isError = false,
    int durationSeconds = 3,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(12),
        duration: Duration(seconds: durationSeconds),
      ),
    );
  }

  // 显示错误消息
  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  // 显示统一风格的确认对话框
  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icon, color: confirmColor, size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '取消',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // 创建新备份
  Future<void> _createBackup() async {
    // 先检查权限
    if (!_hasStoragePermission) {
      final hasPermission = await PermissionHelper.requestStoragePermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = '未获得存储权限，无法创建备份';
        });
        _showSnackBar(
          message: '未获得存储权限，无法创建备份',
          isError: true,
        );
        return;
      }
      setState(() {
        _hasStoragePermission = true;
      });
    }
    
    setState(() {
      _isCreatingBackup = true;
      _errorMessage = null;
    });

    try {
      final backupPath = await _backupService.backupDatabase();
      // 重新加载备份列表
      await _loadBackups();
      _showSnackBar(
        message: '数据备份成功：$backupPath',
        isError: false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = '备份失败: $e';
      });
      _showSnackBar(
        message: '备份失败: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isCreatingBackup = false;
      });
    }
  }

  // 导出数据为JSON
  Future<void> _exportDataToJson() async {
    // 先检查权限
    if (!_hasStoragePermission) {
      final hasPermission = await PermissionHelper.requestStoragePermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = '未获得存储权限，无法导出数据';
        });
        _showSnackBar(
          message: '未获得存储权限，无法导出数据',
          isError: true,
        );
        return;
      }
      setState(() {
        _hasStoragePermission = true;
      });
    }
    
    setState(() {
      _isExportingJson = true;
      _errorMessage = null;
    });

    try {
      final exportPath = await _backupService.exportDataToJson();
      // 重新加载备份列表
      await _loadBackups();
      _showSnackBar(
        message: '数据导出成功：$exportPath',
        isError: false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = '导出失败: $e';
      });
      _showSnackBar(
        message: '导出失败: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isExportingJson = false;
      });
    }
  }

  // 从备份恢复
  Future<void> _restoreFromBackup(String backupPath) async {
    // 显示确认对话框
    final bool? confirm = await _showConfirmDialog(
      title: '确认恢复',
      content: '从备份恢复将覆盖当前的所有数据，确定要继续吗？',
      confirmText: '确定恢复',
      confirmColor: AppColors.info,
      icon: Icons.restore,
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _backupService.restoreDatabase(backupPath);
      _showSnackBar(
        message: '数据恢复成功，请重启应用',
        isError: false,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '恢复失败: $e';
        _isLoading = false;
      });
      _showSnackBar(
        message: '恢复失败: $e',
        isError: true,
      );
    }
  }

  // 从JSON备份文件恢复数据
  Future<void> _restoreFromJsonBackup(String jsonFilePath) async {
    // 显示确认对话框
    final bool? confirm = await _showConfirmDialog(
      title: '确认恢复',
      content: '从JSON备份恢复将覆盖当前的所有数据，确定要继续吗？',
      confirmText: '确定恢复',
      confirmColor: AppColors.info,
      icon: Icons.restore,
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _backupService.importDataFromJson(jsonFilePath);
      _showSnackBar(
        message: '数据恢复成功，请重启应用',
        isError: false,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '恢复失败: $e';
        _isLoading = false;
      });
      _showSnackBar(
        message: '恢复失败: $e',
        isError: true,
      );
    }
  }

  // 删除备份
  Future<void> _deleteBackup(String backupPath) async {
    // 显示确认对话框
    final bool? confirm = await _showConfirmDialog(
      title: '确认删除',
      content: '确定要删除这个备份文件吗？此操作不可恢复！',
      confirmText: '确定删除',
      confirmColor: AppColors.error,
      icon: Icons.delete_forever,
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _backupService.deleteBackupFile(backupPath);
      await _loadBackups();
      _showSnackBar(
        message: '备份文件已删除',
        isError: false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = '删除失败: $e';
        _isLoading = false;
      });
      _showSnackBar(
        message: '删除失败: $e',
        isError: true,
      );
    }
  }
  
  // 分享备份文件
  Future<void> _shareBackup(String filePath) async {
    try {
      await _backupService.shareBackupFile(filePath);
    } catch (e) {
      _showSnackBar(
        message: '分享失败: $e',
        isError: true,
      );
    }
  }

  // 格式化文件大小
  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      final kb = sizeInBytes / 1024;
      return '${kb.toStringAsFixed(2)} KB';
    } else {
      final mb = sizeInBytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} MB';
    }
  }

  // 从文件路径中提取日期时间
  String _extractDateTimeFromPath(String filePath) {
    final fileName = path.basename(filePath);
    if (fileName.contains('_')) {
      try {
        final parts = fileName.split('_');
        if (parts.length >= 2) {
          final datePart = parts[1];
          final timePart = parts[2].split('.').first;
          
          // 解析日期和时间
          final year = datePart.substring(0, 4);
          final month = datePart.substring(4, 6);
          final day = datePart.substring(6, 8);
          
          final hour = timePart.substring(0, 2);
          final minute = timePart.substring(2, 4);
          final second = timePart.substring(4, 6);
          
          return '$year-$month-$day $hour:$minute:$second';
        }
      } catch (e) {
        // 如果解析失败，返回文件修改时间
        final file = File(filePath);
        final lastModified = file.lastModifiedSync();
        return DateFormat('yyyy-MM-dd HH:mm:ss').format(lastModified);
      }
    }
    
    // 默认返回文件修改时间
    final file = File(filePath);
    final lastModified = file.lastModifiedSync();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(lastModified);
  }

  // 导入JSON数据
  Future<void> _importDataFromJson() async {
    // 先检查权限
    if (!_hasStoragePermission) {
      final hasPermission = await PermissionHelper.requestStoragePermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = '未获得存储权限，无法导入数据';
        });
        _showSnackBar(
          message: '未获得存储权限，无法导入数据',
          isError: true,
        );
        return;
      }
      setState(() {
        _hasStoragePermission = true;
      });
    }
    
    try {
      // 使用文件选择器选择JSON文件
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.single.path != null) {
        // 显示确认对话框
        final bool? confirm = await _showConfirmDialog(
          title: '确认导入',
          content: '导入数据将覆盖当前的所有数据，确定要继续吗？',
          confirmText: '确定导入',
          confirmColor: AppColors.warning,
          icon: Icons.upload_file,
        );

        if (confirm != true) return;
        
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        
        // 导入数据
        final filePath = result.files.single.path!;
        await _backupService.importDataFromJson(filePath);
        
        // 提示成功
        _showSnackBar(
          message: '数据导入成功，请重启应用',
          isError: false,
        );
        
        // 重新加载备份列表
        await _loadBackups();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '导入失败: $e';
        _isLoading = false;
      });
      _showSnackBar(
        message: '导入失败: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('数据备份'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasStoragePermission
              ? _buildPermissionRequest()
              : Column(
                  children: [
                    // 备份目录信息
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                '备份存储位置',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _backupDirPath,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 标签页切换
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeTab = 'database';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: _activeTab == 'database' ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '数据库备份',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _activeTab == 'database' ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeTab = 'json';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: _activeTab == 'json' ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'JSON备份',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _activeTab == 'json' ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 创建备份按钮
                    if (_activeTab == 'database')
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: _isCreatingBackup ? null : _createBackup,
                          icon: _isCreatingBackup
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            _isCreatingBackup ? '正在备份...' : '创建新备份',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColors.primaryWithOpacity10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                        ),
                      ),
                      
                    // JSON数据导出导入按钮
                    if (_activeTab == 'json')
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isExportingJson ? null : _exportDataToJson,
                                icon: _isExportingJson
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.upload_file, color: Colors.white),
                                label: Text(
                                  _isExportingJson ? '导出中...' : '导出为JSON',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(54),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: AppColors.primaryWithOpacity10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _importDataFromJson,
                                icon: const Icon(Icons.download_rounded, color: Colors.white),
                                label: const Text(
                                  '导入JSON',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(54),
                                  backgroundColor: Colors.amber[700],
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: Colors.amber.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 错误信息
                    _buildErrorMessage(),

                    // 备份文件列表
                    Expanded(
                      child: _activeTab == 'database'
                          ? (_backupFiles.isEmpty
                              ? _buildEmptyState(
                                  icon: Icons.backup_outlined,
                                  message: '没有备份文件',
                                  description: '点击上方按钮创建一个新的数据库备份',
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemCount: _backupFiles.length,
                                  itemBuilder: (context, index) {
                                    final backupFile = _backupFiles[index] as File;
                                    final fileSize = backupFile.lengthSync();
                                    final formattedSize = _formatFileSize(fileSize);
                                    final dateTime = _extractDateTimeFromPath(backupFile.path);

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      elevation: 2,
                                      shadowColor: Colors.black26,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryLight,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.storage,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              title: Text(
                                                '备份时间: $dateTime',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text('文件大小: $formattedSize'),
                                            ),
                                            const Divider(height: 4),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () => _restoreFromBackup(backupFile.path),
                                                    icon: const Icon(Icons.restore, size: 18),
                                                    label: const Text('恢复'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: AppColors.info,
                                                    ),
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () => _shareBackup(backupFile.path),
                                                    icon: const Icon(Icons.share, size: 18),
                                                    label: const Text('分享'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: AppColors.success,
                                                    ),
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () => _deleteBackup(backupFile.path),
                                                    icon: const Icon(Icons.delete, size: 18),
                                                    label: const Text('删除'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: AppColors.error,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ))
                          : (_jsonBackupFiles.isEmpty
                              ? _buildEmptyState(
                                  icon: Icons.data_object,
                                  message: '没有JSON备份文件',
                                  description: '点击上方按钮导出一个新的JSON备份',
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemCount: _jsonBackupFiles.length,
                                  itemBuilder: (context, index) {
                                    final jsonFile = _jsonBackupFiles[index] as File;
                                    final fileSize = jsonFile.lengthSync();
                                    final formattedSize = _formatFileSize(fileSize);
                                    final dateTime = _extractDateTimeFromPath(jsonFile.path);

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      elevation: 2,
                                      shadowColor: Colors.black26,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.data_object,
                                                  color: Colors.amber[700],
                                                ),
                                              ),
                                              title: Text(
                                                '导出时间: $dateTime',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text('文件大小: $formattedSize'),
                                            ),
                                            const Divider(height: 4),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () => _restoreFromJsonBackup(jsonFile.path),
                                                    icon: const Icon(Icons.restore, size: 18),
                                                    label: const Text('恢复'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: AppColors.info,
                                                    ),
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () => _shareBackup(jsonFile.path),
                                                    icon: const Icon(Icons.share, size: 18),
                                                    label: const Text('分享'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: AppColors.success,
                                                    ),
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () => _deleteBackup(jsonFile.path),
                                                    icon: const Icon(Icons.delete, size: 18),
                                                    label: const Text('删除'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: AppColors.error,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )),
                    ),
                  ],
                ),
    );
  }
  
  // 构建权限请求视图
  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              '需要存储权限',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '要备份和恢复数据，应用需要访问设备存储空间的权限。\n\n备份文件将存储在设备的应用专用目录中。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: () => _checkPermissionAndLoadBackups(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('授予权限'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String description,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 