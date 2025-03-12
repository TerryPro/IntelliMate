import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intellimate/app/di/service_locator.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_theme.dart';
import 'package:intellimate/domain/repositories/goal_repository.dart';
import 'package:intellimate/domain/repositories/user_repository.dart';
import 'package:intellimate/presentation/providers/daily_note_provider.dart';
import 'package:intellimate/presentation/providers/finance_provider.dart';
import 'package:intellimate/presentation/providers/goal_provider.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:intellimate/presentation/providers/note_provider.dart';
import 'package:intellimate/presentation/providers/password_provider.dart';
import 'package:intellimate/presentation/providers/schedule_provider.dart';
import 'package:intellimate/presentation/providers/task_provider.dart';
import 'package:intellimate/presentation/providers/user_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 根据平台选择合适的数据库实现
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 在桌面平台上初始化sqflite_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('使用 sqflite_ffi 初始化 databaseFactory (桌面平台)');
  } else {
    print('使用默认 sqflite 实现 (移动平台)');
  }
  
  // 设置状态栏颜色
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 初始化日期格式化
  await initializeDateFormatting('zh_CN', null);
  
  // 初始化服务定位器
  await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(sl<UserRepository>())),
        ChangeNotifierProvider(create: (_) => GoalProvider(sl<GoalRepository>())),
        ChangeNotifierProvider(create: (_) => sl<NoteProvider>()),
        ChangeNotifierProvider(create: (_) => sl<TaskProvider>()),
        ChangeNotifierProvider(create: (_) => sl<DailyNoteProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ScheduleProvider>()),
        ChangeNotifierProvider(create: (_) => sl<MemoProvider>()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
      ],
      child: MaterialApp(
        title: 'IntelliMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: [
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
