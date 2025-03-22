import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/goal.dart';
import 'package:intellimate/presentation/providers/goal_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String _selectedFilter = '全部';

  // 修改筛选选项为目标类型
  final List<String> _filters = ['全部', '周目标', '月目标', '季目标', '年目标'];

  // 添加新目标
  void _addGoal() {
    Navigator.pushNamed(context, AppRoutes.addGoal).then((result) {
      if (result == true && mounted) {
        // 刷新数据
        Provider.of<GoalProvider>(context, listen: false).loadGoals();
      }
    });
  }

  // 编辑目标
  void _editGoal(Goal goal) {
    Navigator.pushNamed(
      context,
      AppRoutes.editGoal,
      arguments: goal,
    ).then((result) {
      if (result == true && mounted) {
        // 刷新数据
        Provider.of<GoalProvider>(context, listen: false).loadGoals();
      }
    });
  }

  // 删除目标
  void _deleteGoal(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个目标吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GoalProvider>(context, listen: false).deleteGoal(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('目标已删除')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 修改筛选逻辑
  List<Goal> _getFilteredGoals(List<Goal> goals) {
    if (_selectedFilter == '全部') {
      return goals;
    } else {
      return goals.where((goal) => goal.category == _selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          final goals = goalProvider.goals;

          if (goalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (goalProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${goalProvider.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => goalProvider.loadGoals(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 使用统一的顶部导航栏
              UnifiedAppBar(
                title: '目标管理',
                actions: [
                  AppBarRefreshButton(
                    onTap: () =>
                        Provider.of<GoalProvider>(context, listen: false)
                            .loadGoals(),
                  ),
                  const SizedBox(width: 8),
                  AppBarAddButton(
                    onTap: _addGoal,
                  ),
                ],
              ),

              // 主体内容
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 时间周期选择
                        _buildTimeFilter(),

                        // 周目标
                        _buildWeeklyGoals(goals),

                        // 月目标
                        _buildMonthlyGoals(goals),

                        // 季度目标
                        _buildQuarterlyGoals(goals),

                        // 年目标
                        _buildYearlyGoals(goals),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 修改时间筛选器为目标类型筛选器
  Widget _buildTimeFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          final count = Provider.of<GoalProvider>(context)
              .goals
              .where((goal) => filter == '全部' ? true : goal.category == filter)
              .length;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3ECABB).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF3ECABB)
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filter == '全部' ? '全部' : filter.substring(0, 1),
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? const Color(0xFF3ECABB)
                          : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 构建周目标
  Widget _buildWeeklyGoals(List<Goal> goals) {
    if (_selectedFilter != '全部' && _selectedFilter != '周目标') {
      return const SizedBox.shrink();
    }

    final weeklyGoals = _getFilteredGoals(goals)
        .where((goal) => goal.category == '周目标')
        .toList();

    return _buildGoalSection(
      title: '周目标',
      goals: weeklyGoals,
    );
  }

  // 构建月目标
  Widget _buildMonthlyGoals(List<Goal> goals) {
    if (_selectedFilter != '全部' && _selectedFilter != '月目标') {
      return const SizedBox.shrink();
    }

    final monthlyGoals = _getFilteredGoals(goals)
        .where((goal) => goal.category == '月目标')
        .toList();

    return _buildGoalSection(
      title: '月目标',
      goals: monthlyGoals,
    );
  }

  // 构建季度目标
  Widget _buildQuarterlyGoals(List<Goal> goals) {
    if (_selectedFilter != '全部' && _selectedFilter != '季目标') {
      return const SizedBox.shrink();
    }

    final quarterlyGoals = _getFilteredGoals(goals)
        .where((goal) => goal.category == '季目标')
        .toList();

    return _buildGoalSection(
      title: '季目标',
      goals: quarterlyGoals,
    );
  }

  // 构建年度目标
  Widget _buildYearlyGoals(List<Goal> goals) {
    if (_selectedFilter != '全部' && _selectedFilter != '年目标') {
      return const SizedBox.shrink();
    }

    final yearlyGoals = _getFilteredGoals(goals)
        .where((goal) => goal.category == '年目标')
        .toList();

    return _buildGoalSection(
      title: '年目标',
      goals: yearlyGoals,
    );
  }

  // 构建目标区块
  Widget _buildGoalSection({
    required String title,
    required List<Goal> goals,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${goals.length}个目标',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.flag,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无${title.substring(0, 1)}期目标',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return _buildGoalItem(goal);
              },
            ),
        ],
      ),
    );
  }

  // 构建目标项
  Widget _buildGoalItem(Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // 完成率和状态显示在同一行
              Row(
                children: [
                  Text(
                    '完成率: ${goal.progress.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(goal.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(goal.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (goal.description != null && goal.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                goal.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation<Color>(_getStatusColor(goal.status)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 时间信息放到最后一行最左边
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('yyyy/MM/dd').format(goal.startDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Text(
                      ' - ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      goal.endDate != null
                          ? DateFormat('yyyy/MM/dd').format(goal.endDate!)
                          : '无截止日期',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              // 操作按钮放到最后一行最右边，并缩小按钮尺寸
              Row(
                children: [
                  // 编辑按钮
                  GestureDetector(
                    onTap: () => _editGoal(goal),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 删除按钮
                  GestureDetector(
                    onTap: () => _deleteGoal(goal.id),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '未开始':
        return Colors.grey;
      case '进行中':
        return Colors.blue;
      case '已完成':
        return Colors.green;
      case '已放弃':
        return Colors.red;
      case '落后':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
