import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:path/path.dart';
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
      final path = join(databasesPath, DatabaseHelper.databaseName);

      // 获取数据库表信息
      final db = await DatabaseHelper.instance.database;
      final tables = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

      setState(() {
        _databasePath = path;
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
