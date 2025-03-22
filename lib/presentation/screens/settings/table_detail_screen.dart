import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/data/datasources/database_helper.dart';

class TableDetailScreen extends StatefulWidget {
  final String tableName;

  const TableDetailScreen({Key? key, required this.tableName})
      : super(key: key);

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  List<Map<String, dynamic>> _tableStructure = [];
  List<Map<String, dynamic>> _tableData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTableInfo();
  }

  Future<void> _loadTableInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await DatabaseHelper.instance.database;

      // 获取表结构信息
      final structure =
          await db.rawQuery('PRAGMA table_info(${widget.tableName})');

      // 获取表数据
      final data = await db.rawQuery('SELECT * FROM ${widget.tableName}');

      setState(() {
        _tableStructure = structure;
        _tableData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('加载表信息失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.tableName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 表结构信息
                  _buildTableStructureCard(),

                  const SizedBox(height: 16),

                  // 表数据信息
                  _buildTableDataCard(),
                ],
              ),
            ),
    );
  }

  // 构建表结构信息卡片
  Widget _buildTableStructureCard() {
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
          const Text(
            '表结构',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('cid')),
                DataColumn(label: Text('name')),
                DataColumn(label: Text('type')),
                DataColumn(label: Text('notnull')),
                DataColumn(label: Text('dflt_value')),
                DataColumn(label: Text('pk')),
              ],
              rows: _tableStructure
                  .map((row) => DataRow(cells: [
                        DataCell(Text(row['cid'].toString())),
                        DataCell(Text(row['name'].toString())),
                        DataCell(Text(row['type'].toString())),
                        DataCell(Text(row['notnull'].toString())),
                        DataCell(Text(row['dflt_value'].toString())),
                        DataCell(Text(row['pk'].toString())),
                      ]))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 构建表数据信息卡片
  Widget _buildTableDataCard() {
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
          const Text(
            '表数据',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: _tableStructure
                  .map((row) => DataColumn(label: Text(row['name'].toString())))
                  .toList(),
              rows: _tableData.map((row) {
                return DataRow(
                  cells: _tableStructure.map((col) {
                    return DataCell(Text(row[col['name']].toString()));
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
