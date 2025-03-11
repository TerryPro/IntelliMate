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
  late int _currentIndex;
  late final PageController _pageController;

  // 页面列表
  final List<Widget> _pages = [
    const HomePage(),               // 首页
    const DailyNoteScreen(),        // 点滴 - 日常点滴页面
    const NoteScreen(),             // 笔记 - 笔记管理页面
    const ScheduleScreen(),         // 日常 - 日程管理页面
    const TaskScreen(),             // 任务 - 任务管理页面
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 处理底部导航栏点击事件
  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  // 导航帮助类可以访问的方法
  static void navigateToTabIndex(_HomeScreenState state, int index) {
    state._onNavItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    // 检查是否需要处理路由参数
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('initialTabIndex')) {
      final tabIndex = args['initialTabIndex'] as int;
      if (tabIndex != _currentIndex) {
        // 使用Future.microtask确保在构建完成后再切换页面
        Future.microtask(() {
          _onNavItemTapped(tabIndex);
        });
      }
    }
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      // 无需浮动添加按钮，已在首页添加了"更多操作"按钮
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}

// 首页内容
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用AssistantScreen作为首页内容
    return const AssistantScreen();
  }
} 