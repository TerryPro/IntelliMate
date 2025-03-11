import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dependency_injection.dart' as di;
import 'package:intellimate/presentation/providers/note_provider.dart';
import 'package:intellimate/presentation/pages/note_test_page.dart';
import 'package:intellimate/app/theme/app_theme.dart';
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
  
  // 初始化依赖注入
  await di.init();
  runApp(const MyNoteTestApp());
}

class MyNoteTestApp extends StatelessWidget {
  const MyNoteTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => di.serviceLocator<NoteProvider>(),
      child: MaterialApp(
        title: '笔记测试',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const NoteTestPage(),
      ),
    );
  }
} 