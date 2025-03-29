import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/utils/backup_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class DataExportImportScreen extends StatefulWidget {
  final int initialTab;
  
  const DataExportImportScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<DataExportImportScreen> createState() => _DataExportImportScreenState();
}

class _DataExportImportScreenState extends State<DataExportImportScreen> with SingleTickerProviderStateMixin {
  final BackupService _backupService = BackupService.instance;
  bool _isExporting = false;
  bool _isImporting = false;
  String? _errorMessage;
  String? _successMessage;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 导出数据
  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final exportPath = await _backupService.exportDataToJson();
      setState(() {
        _successMessage = '数据已成功导出到: $exportPath';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据导出成功')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = '导出失败: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // 导入数据
  Future<void> _importData() async {
    // 显示文件选择器
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return; // 用户取消了文件选择
    }

    final filePath = result.files.single.path!;
    final fileName = path.basename(filePath);

    // 显示确认对话框
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认导入'),
        content: Text('确定要导入 $fileName 吗？\n导入可能会覆盖现有数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _backupService.importDataFromJson(filePath);
      setState(() {
        _successMessage = '数据导入成功';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据导入成功')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = '导入失败: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }
  
  // 构建数据导出标签页
  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 数据导出部分
          const Text(
            '数据导出',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '将应用中的所有数据导出为JSON格式，可用于备份或迁移数据。',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isExporting ? null : _exportData,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('导出数据'),
          ),
          
          const SizedBox(height: 24),
          
          // 成功消息
          if (_successMessage != null && _tabController.index == 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
            
          // 错误消息
          if (_errorMessage != null && _tabController.index == 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
            
          const SizedBox(height: 24),
          
          // 注意事项
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '导出说明',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. 导出的数据不包含敏感账号信息',
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  '2. 导出文件保存在应用数据目录下的backup文件夹中',
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  '3. 导出操作可能需要几秒钟时间，请耐心等待',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建数据导入标签页
  Widget _buildImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 数据导入部分
          const Text(
            '数据导入',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '从JSON文件导入数据，将合并或覆盖现有数据。请在导入前先备份您的数据。',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isImporting ? null : _importData,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isImporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('选择文件并导入'),
          ),
          
          const SizedBox(height: 24),
          
          // 成功消息
          if (_successMessage != null && _tabController.index == 1)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
            
          // 错误消息
          if (_errorMessage != null && _tabController.index == 1)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
            
          const SizedBox(height: 24),
          
          // 注意事项
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '导入注意事项',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. 导入前建议先备份现有数据',
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  '2. 只能导入本应用导出的JSON格式数据',
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  '3. 导入操作可能需要几分钟时间，请耐心等待',
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  '4. 导入数据将与现有数据合并，可能造成数据冲突',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('数据导入导出'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.file_upload),
              text: '数据导出',
            ),
            Tab(
              icon: Icon(Icons.file_download),
              text: '数据导入',
            ),
          ],
          onTap: (index) {
            // 重置消息
            setState(() {
              _errorMessage = null;
              _successMessage = null;
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExportTab(),
          _buildImportTab(),
        ],
      ),
    );
  }
} 