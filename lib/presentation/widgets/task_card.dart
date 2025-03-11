import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_theme.dart';
import 'package:intellimate/domain/entities/task.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(bool) onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 优先级颜色
    Color priorityColor;
    switch (task.priority) {
      case 3:
        priorityColor = AppTheme.errorColor;
        break;
      case 2:
        priorityColor = AppTheme.warningColor;
        break;
      case 1:
        priorityColor = AppTheme.infoColor;
        break;
      default:
        priorityColor = AppTheme.secondaryColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 任务状态复选框
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) => onStatusChanged(value ?? false),
                  activeColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 任务内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 优先级标记
                        if (task.priority != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getPriorityText(task.priority),
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // 分类标签
                        if (task.category != null && task.category!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryVeryLightColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.category!,
                              style: const TextStyle(
                                color: AppTheme.primaryDarkColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 任务标题
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      // 任务描述
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 8),
                      // 截止日期
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: _isOverdue(task.dueDate!) ? AppTheme.errorColor : AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: _isOverdue(task.dueDate!) ? AppTheme.errorColor : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // 右侧箭头
              const Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 获取优先级文本
  String _getPriorityText(int? priority) {
    switch (priority) {
      case 3:
        return '高';
      case 2:
        return '中';
      case 1:
        return '低';
      default:
        return '无';
    }
  }

  // 判断是否已过期
  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now()) && !task.isCompleted;
  }
} 