import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intellimate/domain/entities/goal.dart';
import 'package:intellimate/presentation/screens/login/login_screen.dart';
import 'package:intellimate/presentation/screens/assistant/assistant_screen.dart';
import 'package:intellimate/presentation/screens/schedule/schedule_screen.dart';
import 'package:intellimate/presentation/screens/schedule/add_schedule_screen.dart';
import 'package:intellimate/presentation/screens/task/task_screen.dart';
import 'package:intellimate/presentation/screens/task/add_task_screen.dart';
import 'package:intellimate/presentation/screens/daily_note/daily_note_screen.dart';
import 'package:intellimate/presentation/screens/daily_note/add_daily_note_screen.dart';
import 'package:intellimate/presentation/screens/note/note_screen.dart';
import 'package:intellimate/presentation/screens/note/write_note_screen.dart';
import 'package:intellimate/presentation/screens/finance/finance_screen.dart';
import 'package:intellimate/presentation/screens/finance/add_finance_screen.dart';
import 'package:intellimate/presentation/screens/photo/photo_gallery_screen.dart';
import 'package:intellimate/presentation/screens/photo/album_detail_screen.dart';
import 'package:intellimate/presentation/screens/goal/goal_screen.dart';
import 'package:intellimate/presentation/screens/travel/travel_screen.dart';
import 'package:intellimate/presentation/screens/travel/travel_detail_screen.dart';
import 'package:intellimate/presentation/screens/memo/memo_screen.dart';
import 'package:intellimate/presentation/screens/memo/add_memo_screen.dart';
import 'package:intellimate/presentation/screens/memo/edit_memo_screen.dart';
import 'package:intellimate/presentation/screens/settings/settings_screen.dart';
import 'package:intellimate/presentation/screens/settings/profile_edit_screen.dart';
import 'package:intellimate/presentation/screens/settings/password_change_screen.dart';
import 'package:intellimate/presentation/screens/home/home_screen.dart';
import 'package:intellimate/presentation/screens/splash/splash_screen.dart';
import 'package:intellimate/presentation/screens/placeholder_screen.dart';
import 'package:intellimate/presentation/screens/goal/add_goal_screen.dart';

class AppRoutes {
  // 路由名称常量
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String assistant = '/assistant';
  static const String schedule = '/schedule';
  static const String addSchedule = '/add_schedule';
  static const String task = '/task';
  static const String addTask = '/add_task';
  static const String dailyNote = '/daily_note';
  static const String addDailyNote = '/add_daily_note';
  static const String note = '/note';
  static const String writeNote = '/note/write';
  static const String finance = '/finance';
  static const String addFinance = '/finance/add';
  static const String photoGallery = '/photo_gallery';
  static const String albumDetail = '/photo_gallery/album';
  static const String goal = '/goal';
  static const String addGoal = '/goal/add';
  static const String editGoal = '/goal/edit';
  static const String travel = '/travel';
  static const String travelDetail = '/travel/detail';
  static const String memo = '/memo';
  static const String addMemo = '/add_memo';
  static const String editMemo = '/edit_memo';
  static const String settings = '/settings';
  static const String profileEdit = '/settings/profile';
  static const String passwordChange = '/settings/password';
  static const String dataManagement = '/settings/data';
  static const String reminder = '/reminder';
  
  // 路由表
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      home: (context) {
        // 获取路由参数
        final args = ModalRoute.of(context)?.settings.arguments;
        int initialTabIndex = 0;
        if (args is Map<String, dynamic> && args.containsKey('initialTabIndex')) {
          initialTabIndex = args['initialTabIndex'] as int;
        }
        return HomeScreen(initialTabIndex: initialTabIndex);
      },
      assistant: (context) => const AssistantScreen(),
      // 日程管理模块
      schedule: (context) => const ScheduleScreen(),
      addSchedule: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is String) {
          return AddScheduleScreen(scheduleId: args);
        }
        return const AddScheduleScreen();
      },
      // 任务管理模块
      task: (context) => const TaskScreen(),
      addTask: (context) => const AddTaskScreen(),
      // 其他模块使用临时占位页面
      dailyNote: (context) => const DailyNoteScreen(),
      addDailyNote: (context) => const AddDailyNoteScreen(),
      note: (context) => const NoteScreen(),
      writeNote: (context) => const WriteNoteScreen(),
      finance: (context) => const FinanceScreen(),
      addFinance: (context) => const AddFinanceScreen(),
      photoGallery: (context) => const PhotoGalleryScreen(),
      albumDetail: (context) {
        final album = ModalRoute.of(context)?.settings.arguments as PhotoAlbum;
        return AlbumDetailScreen(album: album);
      },
      goal: (context) => const GoalScreen(),
      addGoal: (context) => const AddGoalScreen(),
      editGoal: (context) {
        final goal = ModalRoute.of(context)?.settings.arguments as Goal;
        return AddGoalScreen(goal: goal);
      },
      travel: (context) => const TravelScreen(),
      travelDetail: (context) {
        final travel = ModalRoute.of(context)?.settings.arguments as Travel;
        return TravelDetailScreen(travel: travel);
      },
      memo: (context) => const MemoScreen(),
      addMemo: (context) => const AddMemoScreen(),
      editMemo: (context) => const EditMemoScreen(),
      settings: (context) => const SettingsScreen(),
      profileEdit: (context) => const ProfileEditScreen(),
      passwordChange: (context) => const PasswordChangeScreen(),
      dataManagement: (context) => const PlaceholderScreen(
        title: '数据管理',
        icon: Icons.storage,
        moduleKey: 'settings',
      ),
      reminder: (context) => const PlaceholderScreen(
        title: '设置提醒',
        icon: Icons.notifications_active,
        moduleKey: 'schedule',
      ),
    };
  }
  
  // 初始路由
  static String getInitialRoute() {
    return splash;
  }
  
  // 未知路由处理
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('页面未找到'),
        ),
        body: const Center(
          child: Text('抱歉，请求的页面不存在'),
        ),
      ),
    );
  }
} 