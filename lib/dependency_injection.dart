import 'package:get_it/get_it.dart';
import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/datasources/note_datasource.dart';
import 'package:intellimate/data/repositories/note_repository_impl.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/usecases/note/create_note.dart';
import 'package:intellimate/domain/usecases/note/delete_note.dart';
import 'package:intellimate/domain/usecases/note/get_all_notes.dart';
import 'package:intellimate/domain/usecases/note/get_note_by_id.dart';
import 'package:intellimate/domain/usecases/note/search_notes.dart';
import 'package:intellimate/domain/usecases/note/update_note.dart';
import 'package:intellimate/presentation/providers/note_provider.dart';

// 服务定位器实例
final serviceLocator = GetIt.instance;

// 初始化依赖注入
Future<void> init() async {
  print('开始初始化依赖注入...');

  // 确保数据库已初始化
  await DatabaseHelper.instance.ensureInitialized();
  print('数据库已初始化');

  // 数据源
  serviceLocator.registerLazySingleton<NoteDataSource>(
    () => NoteDataSourceImpl(),
  );
  print('注册NoteDataSource完成');

  // 存储库
  serviceLocator.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(dataSource: serviceLocator()),
  );
  print('注册NoteRepository完成');

  // 用例
  serviceLocator.registerLazySingleton(() => GetAllNotes(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetNoteById(serviceLocator()));
  serviceLocator.registerLazySingleton(() => CreateNote(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UpdateNote(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeleteNote(serviceLocator()));
  serviceLocator.registerLazySingleton(() => SearchNotes(serviceLocator()));
  print('注册用例完成');

  // 提供者
  serviceLocator.registerFactory(() => NoteProvider(
        getAllNotes: serviceLocator(),
        getNoteById: serviceLocator(),
        createNote: serviceLocator(),
        updateNote: serviceLocator(),
        deleteNote: serviceLocator(),
        searchNotes: serviceLocator(),
      ));
  print('注册NoteProvider完成');

  print('依赖注入初始化完成');
} 