import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/presentation/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:intellimate/presentation/screens/task/task_panel.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String _selectedFilter = '全部';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // 加载任务数据
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TaskProvider>(context, listen: false).loadTasks();
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载任务失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 获取筛选后的任务列表
  List<Task> _getFilteredTasks(List<Task> allTasks) {
    if (_selectedFilter == '全部') {
      return allTasks;
    } else if (_selectedFilter == '已完成') {
      return allTasks.where((task) => task.isCompleted).toList();
    } else if (_selectedFilter == '未完成') {
      return allTasks.where((task) => !task.isCompleted).toList();
    } else {
      return allTasks;
    }
  }

  // 判断两个日期是否是同一天
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 更新任务完成状态
  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      final success = await Provider.of<TaskProvider>(context, listen: false)
          .updateTaskCompletion(task.id, !task.isCompleted);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新任务状态失败')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新任务状态失败: $e')),
        );
      }
    }
  }

  // 删除任务
  Future<void> _deleteTask(String taskId) async {
    try {
      await Provider.of<TaskProvider>(context, listen: false)
          .deleteTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已删除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除任务失败: $e')),
        );
      }
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

          const SizedBox(height: 20),

          // 任务统计信息
          _buildTaskStatistics(),

          const SizedBox(height: 20),

          // 任务列表
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (taskProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '加载失败: ${taskProvider.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTasks,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredTasks = _getFilteredTasks(taskProvider.tasks);

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.task_alt,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == '全部'
                              ? '没有任务，点击下方按钮添加新任务'
                              : '没有符合条件的任务',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: _buildTaskList(filteredTasks),
                );
              },
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
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF3ECABB),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.home);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '我的任务',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _loadTasks,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF3ECABB),
                    size: 20,
                  ),
                  onPressed: () async {
                    final result =
                        await Navigator.pushNamed(context, AppRoutes.addTask);
                    if (result == true && mounted) {
                      _loadTasks();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建任务统计信息
  Widget _buildTaskStatistics() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final totalTasks = taskProvider.tasks.length;
        final completedTasks =
            taskProvider.tasks.where((task) => task.isCompleted).length;
        final pendingTasks = totalTasks - completedTasks;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatisticItem('全  部', totalTasks, Colors.blue),
              _buildStatisticItem('已完成', completedTasks, Colors.green),
              _buildStatisticItem('未完成', pendingTasks, Colors.red),
            ],
          ),
        );
      },
    );
  }

  // 构建单个统计项
  Widget _buildStatisticItem(String label, int count, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedFilter == label
              ? color.withValues(alpha: 0.2)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建任务列表
  Widget _buildTaskList(List<Task> tasks) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    return TaskPanel(
      tasks: tasks,
      onToggleCompletion: _toggleTaskCompletion,
      onDeleteTask: _deleteTask,
      onEditTask: (String taskId) async {
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.addTask,
          arguments: taskId,
        );
        if (result == true && mounted) {
          _loadTasks();
        }
      },
      isLoading: _isLoading,
      error: provider.error,
      onRetry: _loadTasks,
      selectedFilter: _selectedFilter,
    );
  }
}
