import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intellimate/app/di/service_locator.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_theme.dart';
import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/domain/repositories/goal_repository.dart';
import 'package:intellimate/domain/repositories/travel_repository.dart';
import 'package:intellimate/domain/repositories/user_repository.dart';
import 'package:intellimate/presentation/providers/daily_note_provider.dart';
import 'package:intellimate/presentation/providers/finance_provider.dart';
import 'package:intellimate/presentation/providers/goal_provider.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:intellimate/presentation/providers/note_provider.dart';
import 'package:intellimate/presentation/providers/password_provider.dart';
import 'package:intellimate/presentation/providers/schedule_provider.dart';
import 'package:intellimate/presentation/providers/task_provider.dart';
import 'package:intellimate/presentation/providers/travel_provider.dart';
import 'package:intellimate/presentation/providers/user_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
//import 'package:intellimate/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  await _initializeDatabase();

  // 初始化日期格式化（支持中文日期）
  await initializeDateFormatting('zh_CN', null);

  // 初始化依赖注入
  await setupServiceLocator();

  // 设置系统UI样式（状态栏颜色）
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

Future<void> _initializeDatabase() async {
  // 使用DatabaseHelper单例
  final databaseHelper = DatabaseHelper.instance;

  // 获取数据库实例
  await databaseHelper.database;

  // 删除备忘录表以适应结构变更
  // 备忘录表结构已简化：移除了date、priority、isPinned、isCompleted和completedAt字段

  /*
  AppLogger.log('正在删除旧的备忘录表...');
  try {
    await databaseHelper.dropTable('memos');
    DatabaseHelper.resetInitializationState();
    AppLogger.log('备忘录表删除成功！');
  } catch (e) {
    AppLogger.log('删除备忘录表出错: $e');
  }
  */

  // 初始化完成
  await databaseHelper.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => UserProvider(sl<UserRepository>())),
        ChangeNotifierProvider(
            create: (_) => GoalProvider(sl<GoalRepository>())),
        ChangeNotifierProvider(create: (_) => sl<NoteProvider>()),
        ChangeNotifierProvider(create: (_) => sl<TaskProvider>()),
        ChangeNotifierProvider(create: (_) => sl<DailyNoteProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ScheduleProvider>()),
        ChangeNotifierProvider(create: (_) => sl<MemoProvider>()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
        ChangeNotifierProvider(
            create: (_) => TravelProvider(sl<TravelRepository>())),
      ],
      child: MaterialApp(
        title: 'IntelliMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
