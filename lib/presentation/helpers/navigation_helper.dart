import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_theme.dart';

/// 导航帮助类，用于处理底部导航栏和页面之间的导航
class NavigationHelper {
  /// 根据索引导航到底部导航栏对应的页面
  /// 如果已经在HomeScreen中，则切换底部导航栏
  /// 如果不在HomeScreen中，则使用路由导航
  static void navigateToTab(BuildContext context, int index) {
    // 从NavigatorState获取当前route
    final route = ModalRoute.of(context);
    
    // 检查当前是否在Home页面
    final isInHome = route?.settings.name == AppRoutes.home || 
                     route?.settings.name == '/'; // 应用启动页可能是'/'
    
    if (isInHome) {
      // 如果在HomeScreen内，尝试找到状态管理对象来切换页面
      // 这里我们直接使用Navigator重新进入Home页面并设置初始索引
      // 实际开发中，应该有更好的方法在不重新加载的情况下切换
      Navigator.pushReplacementNamed(
        context, 
        AppRoutes.home,
        arguments: {'initialTabIndex': index}, // 可以传递参数指定初始索引
      );
    } else {
      // 如果不在HomeScreen内，使用路由导航
      switch (index) {
        case 0: 
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          break;
        case 1:
          Navigator.pushNamed(context, AppRoutes.dailyNote);
          break;
        case 2:
          Navigator.pushNamed(context, AppRoutes.note);
          break;
        case 3:
          Navigator.pushNamed(context, AppRoutes.schedule);
          break;
        case 4:
          Navigator.pushNamed(context, AppRoutes.task);
          break;
      }
    }
  }

  /// 显示添加操作的底部菜单
  static void showAddActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Text(
                    '快速添加',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAddActionItem(
                    icon: Icons.task_alt,
                    label: '添加任务',
                    color: AppTheme.moduleColors['task']![0],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.addTask);
                    },
                  ),
                  _buildAddActionItem(
                    icon: Icons.event_note,
                    label: '添加日程',
                    color: AppTheme.moduleColors['schedule']![0],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.addSchedule);
                    },
                  ),
                  _buildAddActionItem(
                    icon: Icons.note_add,
                    label: '添加笔记',
                    color: AppTheme.moduleColors['note']![0],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.writeNote);
                    },
                  ),
                  _buildAddActionItem(
                    icon: Icons.auto_stories,
                    label: '添加点滴',
                    color: AppTheme.moduleColors['daily']![0],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.addDailyNote);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAddActionItem(
                    icon: Icons.account_balance_wallet,
                    label: '添加财务',
                    color: AppTheme.moduleColors['finance']![0],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.addFinance);
                    },
                  ),
                  _buildAddActionItem(
                    icon: Icons.flag,
                    label: '添加目标',
                    color: AppTheme.moduleColors['goal']![0],
                    onTap: () {
                      Navigator.pop(context);
                      // 跳转到添加目标页面
                    },
                  ),
                  _buildAddActionItem(
                    icon: Icons.flight_takeoff,
                    label: '添加旅行',
                    color: AppTheme.moduleColors['travel']![0],
                    onTap: () {
                      Navigator.pop(context);
                      // 跳转到添加旅行页面
                    },
                  ),
                  _buildAddActionItem(
                    icon: Icons.sticky_note_2,
                    label: '添加备忘',
                    color: AppTheme.moduleColors['memo']![0],
                    onTap: () {
                      Navigator.pop(context);
                      // 跳转到添加备忘页面
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryColor,
                  ),
                  child: const Text('取消'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建添加操作项
  static Widget _buildAddActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
} 