import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_theme.dart';
import 'package:intellimate/presentation/screens/assistant/assistant_screen.dart';
import 'package:intellimate/presentation/screens/daily_note/daily_note_screen.dart';
import 'package:intellimate/presentation/screens/note/note_screen.dart';
import 'package:intellimate/presentation/screens/schedule/schedule_screen.dart';
import 'package:intellimate/presentation/screens/task/task_screen.dart';
import 'package:intellimate/presentation/widgets/bottom_nav_bar.dart';
import 'package:intellimate/presentation/helpers/navigation_helper.dart';
import 'package:intellimate/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const HomeScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    
    // 初始化页面列表
    _pages = [
      _buildHomePage(),
      const NoteScreen(),
      const TaskScreen(),
      const DailyNoteScreen(),
      const ScheduleScreen(),
      const AssistantScreen(),
    ];
    
    // 确保页面控制器初始位置正确
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    // 检查是否需要处理路由参数
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic> && args.containsKey('initialTabIndex')) {
      final newIndex = args['initialTabIndex'] as int;
      if (newIndex != _currentIndex) {
        // 确保只在需要的时候更新，避免无限循环
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(newIndex);
        });
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎信息
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '你好，用户',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '今天是 ${_getFormattedDate()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 功能区域
            const Text(
              '功能区',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 功能网格
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  '目标管理',
                  Icons.flag,
                  Colors.blue,
                  AppRoutes.goal,
                ),
                _buildFeatureCard(
                  context,
                  '笔记管理',
                  Icons.note,
                  Colors.green,
                  AppRoutes.note,
                ),
                _buildFeatureCard(
                  context,
                  '任务管理',
                  Icons.task_alt,
                  Colors.orange,
                  AppRoutes.task,
                ),
                _buildFeatureCard(
                  context,
                  '日记',
                  Icons.book,
                  Colors.purple,
                  AppRoutes.dailyNote,
                ),
                _buildFeatureCard(
                  context,
                  '日程安排',
                  Icons.calendar_today,
                  Colors.teal,
                  AppRoutes.schedule,
                ),
                _buildFeatureCard(
                  context,
                  '备忘录',
                  Icons.sticky_note_2,
                  Colors.amber,
                  AppRoutes.memo,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 快速操作
            const Text(
              '快速操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 快速操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  context,
                  '添加笔记',
                  Icons.note_add,
                  AppRoutes.writeNote,
                ),
                _buildQuickActionButton(
                  context,
                  '添加任务',
                  Icons.playlist_add,
                  AppRoutes.addTask,
                ),
                _buildQuickActionButton(
                  context,
                  '添加日程',
                  Icons.event_note,
                  AppRoutes.addSchedule,
                ),
                _buildQuickActionButton(
                  context,
                  '添加备忘',
                  Icons.post_add,
                  AppRoutes.addMemo,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  // 构建主页面
  Widget _buildHomePage() {
    return const Center(
      child: Text('主页内容'),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            Navigator.pushNamed(context, route);
          },
          iconSize: 28,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.year}年${now.month}月${now.day}日 $weekday';
  }
} 