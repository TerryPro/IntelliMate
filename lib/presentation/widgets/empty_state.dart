import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.secondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 预定义的空状态
class EmptyStates {
  // 任务列表为空
  static Widget emptyTasks({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无任务',
      message: '您当前没有任何任务，点击下方按钮添加新任务',
      icon: Icons.task_alt_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加任务',
    );
  }

  // 日程列表为空
  static Widget emptySchedules({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无日程',
      message: '您当前没有任何日程安排，点击下方按钮添加新日程',
      icon: Icons.event_note_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加日程',
    );
  }

  // 笔记列表为空
  static Widget emptyNotes({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无笔记',
      message: '您当前没有任何笔记，点击下方按钮添加新笔记',
      icon: Icons.note_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加笔记',
    );
  }

  // 日常点滴为空
  static Widget emptyDailyNotes({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无点滴',
      message: '您当前没有记录任何日常点滴，点击下方按钮添加新点滴',
      icon: Icons.auto_stories_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加点滴',
    );
  }

  // 财务记录为空
  static Widget emptyFinances({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无财务记录',
      message: '您当前没有任何财务记录，点击下方按钮添加新记录',
      icon: Icons.account_balance_wallet_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加记录',
    );
  }

  // 图片为空
  static Widget emptyPhotos({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无图片',
      message: '您当前没有上传任何图片，点击下方按钮添加新图片',
      icon: Icons.photo_library_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加图片',
    );
  }

  // 目标为空
  static Widget emptyGoals({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无目标',
      message: '您当前没有设定任何目标，点击下方按钮添加新目标',
      icon: Icons.flag_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加目标',
    );
  }

  // 旅行为空
  static Widget emptyTravels({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无旅行',
      message: '您当前没有记录任何旅行，点击下方按钮添加新旅行',
      icon: Icons.flight_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加旅行',
    );
  }

  // 备忘为空
  static Widget emptyMemos({VoidCallback? onActionPressed}) {
    return EmptyState(
      title: '暂无备忘',
      message: '您当前没有任何备忘，点击下方按钮添加新备忘',
      icon: Icons.sticky_note_2_outlined,
      onActionPressed: onActionPressed,
      actionText: '添加备忘',
    );
  }

  // 搜索结果为空
  static Widget emptySearchResults({String? searchTerm}) {
    return EmptyState(
      title: '未找到结果',
      message: searchTerm != null && searchTerm.isNotEmpty
          ? '没有找到与"$searchTerm"相关的内容，请尝试其他关键词'
          : '没有找到相关内容，请尝试其他关键词',
      icon: Icons.search_off_outlined,
    );
  }
} 