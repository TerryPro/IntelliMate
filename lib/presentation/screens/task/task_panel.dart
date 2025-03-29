import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/core/task_config.dart';

class TaskPanel extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onToggleCompletion;
  final Function(String) onDeleteTask;
  final Function(String) onEditTask;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final String selectedFilter;

  const TaskPanel({
    super.key,
    required this.tasks,
    required this.onToggleCompletion,
    required this.onDeleteTask,
    required this.onEditTask,
    required this.isLoading,
    this.error,
    required this.onRetry,
    required this.selectedFilter,
  });

  // 判断两个日期是否是同一天
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '加载失败: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              selectedFilter == '全部' ? '没有任务，点击下方按钮添加新任务' : '没有符合条件的任务',
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
      onRefresh: () async {
        onRetry();
      },
      child: _buildTaskList(tasks),
    );
  }

  // 构建任务列表
  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(task, context);
      },
    );
  }

  // 构建任务项
  Widget _buildTaskItem(Task task, BuildContext context) {
    // 格式化日期
    String formatDate(DateTime date) {
      if (isSameDay(date, DateTime.now())) {
        return '今天';
      } else if (isSameDay(date, DateTime.now().add(const Duration(days: 1)))) {
        return '明天';
      } else {
        return '${date.month}月${date.day}日';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.grey.shade300 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: TaskConfig.getCategoryColor(task.category),
            width: 4,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 任务内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 任务元数据（优先级、分类）
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: [
                            if (task.priority != null)
                              _buildMetadataChip(
                                Icons.flag,
                                TaskConfig.getPriorityText(task.priority!),
                                TaskConfig.getPriorityColor(task.priority!),
                              ),
                            if (task.category != null &&
                                task.category!.isNotEmpty)
                              _buildMetadataChip(
                                Icons.category,
                                task.category!,
                                Colors.grey.shade500,
                              ),
                          ],
                        ),
                        // 完成状态指示器
                        _buildMetadataChip(
                          task.isCompleted ? Icons.check_circle : Icons.pending,
                          task.isCompleted ? "已完成" : "进行中",
                          task.isCompleted ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 任务标题
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // 时间信息和操作按钮
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 时间信息
              if (task.dueDate != null)
                _buildMetadataChip(
                  Icons.calendar_today,
                  formatDate(task.dueDate!),
                  Colors.grey.shade500,
                ),
              Row(
                children: [
                  // 完成按钮
                  GestureDetector(
                    onTap: () => onToggleCompletion(task),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        task.isCompleted ? Icons.refresh : Icons.check,
                        color: Colors.grey.shade500,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 编辑按钮
                  GestureDetector(
                    onTap: () => onEditTask(task.id),
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
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade700,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '确认删除',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '你确定要删除这个任务吗？',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '此操作不可恢复，任务内容将永久删除。',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '任务内容预览：',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (task.description != null && task.description!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          task.description!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            actions: <Widget>[
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: const Text(
                                  '取消',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: const Text(
                                  '确认删除',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        onDeleteTask(task.id);
                      }
                    },
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

  // 构建元数据标签
  Widget _buildMetadataChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
