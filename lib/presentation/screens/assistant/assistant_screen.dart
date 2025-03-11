import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_theme.dart';
import 'package:intellimate/presentation/widgets/module_card.dart';
import 'package:intellimate/presentation/screens/home/home_screen.dart';
import 'package:intellimate/presentation/helpers/navigation_helper.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  // 模拟数据
  final String _userName = '小明';
  final int _totalTasks = 5;
  final int _completedTasks = 2;
  
  // 模拟即将到来的日程
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': '产品讨论会议',
      'time': '14:00 - 15:00',
      'location': '会议室A',
    },
    {
      'title': '健身',
      'time': '18:30 - 20:00',
      'location': '健身中心',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部�?
              _buildHeader(),
              
              // 内容区域
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 欢迎�?
                    Text(
                      '你好$_userName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 任务统计
                    _buildTaskStats(),
                    
                    const SizedBox(height: 24),
                    
                    // 即将到来的日�?
                    _buildUpcomingEvents(),
                    
                    const SizedBox(height: 24),
                    
                    // 快捷操作
                    _buildQuickActions(),
                    
                    const SizedBox(height: 32),
                    
                    // 功能模块
                    _buildModules(),
                    
                    const SizedBox(height: 24),
                    
                    // 更多功能提示
                    _buildMoreFeaturesCard(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建顶部�?
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '我的助理',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {
              // 跳转到个人信息页�?
              Navigator.pushNamed(context, AppRoutes.profileEdit);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建任务统计
  Widget _buildTaskStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日任务',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_totalTasks',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '已完成',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_completedTasks',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建即将到来的日�?
  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '即将到来',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                // 跳转到日程页�?
                Navigator.pushNamed(context, AppRoutes.schedule);
              },
              child: const Text(
                '查看全部',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._upcomingEvents.map((event) => _buildEventCard(event)),
      ],
    );
  }

  // 构建日程卡片
  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(
          left: BorderSide(
            color: AppTheme.primaryColor,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['time'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event['title'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                event['location'],
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建快捷操作
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '快捷操作',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            // 添加一个"更多操作"按钮
            TextButton.icon(
              onPressed: () {
                // 显示添加操作底部菜单
                NavigationHelper.showAddActionSheet(context);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('更多操作'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionItem(
              icon: Icons.add_task,
              label: '新建任务',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addTask);
              },
            ),
            _buildQuickActionItem(
              icon: Icons.event_available,
              label: '添加日程',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addSchedule);
              },
            ),
            _buildQuickActionItem(
              icon: Icons.note_add,
              label: '写笔记',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.writeNote);
              },
            ),
            _buildQuickActionItem(
              icon: Icons.auto_stories,
              label: '添加点滴',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addDailyNote);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 构建快捷操作�?
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 构建功能模块
  Widget _buildModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '功能模块',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            ModuleCard(
              moduleKey: 'schedule',
              title: '日程安排',
              icon: Icons.calendar_today,
              onTap: () {
                // 使用底部导航栏切换
                NavigationHelper.navigateToTab(context, 3); // 3是日程安排的索引
              },
            ),
            ModuleCard(
              moduleKey: 'task',
              title: '任务安排',
              icon: Icons.task_alt,
              onTap: () {
                // 使用底部导航栏切换
                NavigationHelper.navigateToTab(context, 4); // 4是任务安排的索引
              },
            ),
            ModuleCard(
              moduleKey: 'daily',
              title: '日常点滴',
              icon: Icons.auto_stories,
              onTap: () {
                // 使用底部导航栏切换
                NavigationHelper.navigateToTab(context, 1); // 1是日常点滴的索引
              },
            ),
            ModuleCard(
              moduleKey: 'note',
              title: '笔记管理',
              icon: Icons.note,
              onTap: () {
                // 使用底部导航栏切换
                NavigationHelper.navigateToTab(context, 2); // 2是笔记管理的索引
              },
            ),
            ModuleCard(
              moduleKey: 'finance',
              title: '财务管理',
              icon: Icons.account_balance_wallet,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.finance);
              },
            ),
            ModuleCard(
              moduleKey: 'settings',
              title: '系统设置',
              icon: Icons.settings,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
            ModuleCard(
              moduleKey: 'photo',
              title: '图片管理',
              icon: Icons.photo_library,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.photoGallery);
              },
            ),
            ModuleCard(
              moduleKey: 'goal',
              title: '目标管理',
              icon: Icons.flag,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.goal);
              },
            ),
            ModuleCard(
              moduleKey: 'travel',
              title: '旅游管理',
              icon: Icons.flight,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.travel);
              },
            ),
            ModuleCard(
              moduleKey: 'memo',
              title: '备忘管理',
              icon: Icons.sticky_note_2,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.memo);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 构建更多功能提示卡片
  Widget _buildMoreFeaturesCard() {
    return GestureDetector(
      onTap: () {
        // 跳转到功能介绍页�?
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryVeryLightColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '探索更多功能',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '发现更多提升效率的工具',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
} 
