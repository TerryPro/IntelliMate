import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_theme.dart';
import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onTap;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          border: Border.all(
            color: AppTheme.primaryVeryLightColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 左侧时间栏
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              // 日程内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 时间信息
                    Text(
                      _getTimeText(),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 日程标题
                    Text(
                      schedule.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      // 日程描述
                      Text(
                        schedule.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (schedule.location != null && schedule.location!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      // 地点信息
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schedule.location!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // 右侧图标
              Column(
                children: [
                  // 重复图标
                  if (schedule.isRepeated)
                    const Icon(
                      Icons.repeat,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                  const SizedBox(height: 8),
                  // 提醒图标
                  if (schedule.reminder != null)
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                  const SizedBox(height: 8),
                  // 全天图标
                  if (schedule.isAllDay)
                    const Icon(
                      Icons.today_outlined,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 获取时间文本
  String _getTimeText() {
    if (schedule.isAllDay) {
      return '全天 · ${DateFormat('yyyy-MM-dd').format(schedule.startTime)}';
    } else {
      final startTime = DateFormat('HH:mm').format(schedule.startTime);
      final endTime = DateFormat('HH:mm').format(schedule.endTime);
      final date = DateFormat('yyyy-MM-dd').format(schedule.startTime);
      
      return '$startTime - $endTime · $date';
    }
  }
} 