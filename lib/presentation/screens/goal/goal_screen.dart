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
  
  // 时间筛选选项
  final List<String> _filters = ['全部', '本周', '本月', '本季度', '本年度'];
  
  // 添加新目标
  void _addGoal() {
    Navigator.pushNamed(context, AppRoutes.addGoal).then((result) {
      if (result == true) {
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
      if (result == true) {
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
  
  // 获取已完成目标数量
  int _completedGoalsCount(List<Goal> goals) {
    return goals.where((goal) => goal.status == '已完成').length;
  }
  
  // 获取进行中目标数量
  int _inProgressGoalsCount(List<Goal> goals) {
    return goals.where((goal) => goal.status == '进行中' || goal.status == '落后').length;
  }
  
  // 计算总体完成率
  double _overallProgress(List<Goal> goals) {
    if (goals.isEmpty) return 0;
    
    final totalProgress = goals.fold(0.0, (sum, goal) => sum + goal.progress);
    return totalProgress / goals.length;
  }
  
  // 根据筛选获取目标列表
  List<Goal> _getFilteredGoals(List<Goal> goals, String category) {
    final filteredByCategory = goals.where((goal) => goal.category == category).toList();
    
    if (_selectedFilter == '全部') {
      return filteredByCategory;
    } else if (_selectedFilter == '本周') {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      return filteredByCategory.where((goal) => 
        (goal.startDate.isAfter(startOfWeek) || goal.startDate.isAtSameMomentAs(startOfWeek)) && 
        (goal.startDate.isBefore(endOfWeek) || goal.startDate.isAtSameMomentAs(endOfWeek))
      ).toList();
    } else if (_selectedFilter == '本月') {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = (now.month < 12) 
          ? DateTime(now.year, now.month + 1, 0)
          : DateTime(now.year + 1, 1, 0);
      
      return filteredByCategory.where((goal) => 
        (goal.startDate.isAfter(startOfMonth) || goal.startDate.isAtSameMomentAs(startOfMonth)) && 
        (goal.startDate.isBefore(endOfMonth) || goal.startDate.isAtSameMomentAs(endOfMonth))
      ).toList();
    } else if (_selectedFilter == '本季度') {
      final now = DateTime.now();
      final currentQuarter = (now.month - 1) ~/ 3 + 1;
      final startOfQuarter = DateTime(now.year, (currentQuarter - 1) * 3 + 1, 1);
      final endOfQuarter = DateTime(now.year, currentQuarter * 3 + 1, 0);
      
      return filteredByCategory.where((goal) => 
        (goal.startDate.isAfter(startOfQuarter) || goal.startDate.isAtSameMomentAs(startOfQuarter)) && 
        (goal.startDate.isBefore(endOfQuarter) || goal.startDate.isAtSameMomentAs(endOfQuarter))
      ).toList();
    } else if (_selectedFilter == '本年度') {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year, 12, 31);
      
      return filteredByCategory.where((goal) => 
        (goal.startDate.isAfter(startOfYear) || goal.startDate.isAtSameMomentAs(startOfYear)) && 
        (goal.startDate.isBefore(endOfYear) || goal.startDate.isAtSameMomentAs(endOfYear))
      ).toList();
    }
    
    return filteredByCategory;
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
                onTap: () => Provider.of<GoalProvider>(context, listen: false).loadGoals(),
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
                    // 目标概览
                        _buildGoalOverview(goals),
                    
                    // 时间周期选择
                    _buildTimeFilter(),
                    
                    // 周目标
                        _buildWeeklyGoals(goals),
                    
                    // 月目标
                        _buildMonthlyGoals(goals),
                    
                    // 年度目标
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
  
  // 构建目标概览
  Widget _buildGoalOverview(List<Goal> goals) {
    return Container(
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
          const Text(
            '目标概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: '已完成',
                value: _completedGoalsCount(goals).toString(),
              ),
              _buildOverviewItem(
                icon: Icons.hourglass_bottom,
                iconColor: Colors.orange,
                title: '进行中',
                value: _inProgressGoalsCount(goals).toString(),
              ),
              _buildOverviewItem(
                icon: Icons.insights,
                iconColor: const Color(0xFF3ECABB),
                title: '完成率',
                value: '${_overallProgress(goals).toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
    );
  }
  
  // 构建概览项
  Widget _buildOverviewItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Column(
                    children: [
        Icon(
          icon,
          color: iconColor,
          size: 32,
        ),
        const SizedBox(height: 8),
                          Text(
          title,
                    style: TextStyle(
                      fontSize: 14,
            color: Colors.grey[700],
                    ),
                  ),
        const SizedBox(height: 4),
                      Text(
          value,
                        style: const TextStyle(
            fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
    );
  }
  
  // 构建时间筛选器
  Widget _buildTimeFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 40,
      child: ListView.builder(
      scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          
          return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3ECABB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // 构建周目标
  Widget _buildWeeklyGoals(List<Goal> goals) {
    final weeklyGoals = _getFilteredGoals(goals, '周目标');
    
    return _buildGoalSection(
      title: '周目标',
      goals: weeklyGoals,
    );
  }
  
  // 构建月目标
  Widget _buildMonthlyGoals(List<Goal> goals) {
    final monthlyGoals = _getFilteredGoals(goals, '月目标');
    
    return _buildGoalSection(
      title: '月目标',
      goals: monthlyGoals,
    );
  }
  
  // 构建年度目标
  Widget _buildYearlyGoals(List<Goal> goals) {
    final yearlyGoals = _getFilteredGoals(goals, '年度目标');
    
    return _buildGoalSection(
      title: '年度目标',
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
    final statusColor = _getStatusColor(goal.status);
    
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                '完成率: ${goal.progress.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                  color: Colors.grey[700],
                    ),
                  ),
              Row(
                children: [
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
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 编辑按钮
              GestureDetector(
                onTap: () => _editGoal(goal),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 删除按钮
              GestureDetector(
                onTap: () => _deleteGoal(goal.id),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                ),
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