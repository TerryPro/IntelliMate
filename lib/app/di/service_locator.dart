import 'package:get_it/get_it.dart';
import 'package:intellimate/data/datasources/daily_note_datasource.dart';
import 'package:intellimate/data/datasources/goal_datasource.dart';
import 'package:intellimate/data/datasources/note_datasource.dart';
import 'package:intellimate/data/datasources/task_datasource.dart';
import 'package:intellimate/data/datasources/user_datasource.dart';
import 'package:intellimate/data/repositories/daily_note_repository_impl.dart';
import 'package:intellimate/data/repositories/goal_repository_impl.dart';
import 'package:intellimate/data/repositories/note_repository_impl.dart';
import 'package:intellimate/data/repositories/task_repository_impl.dart';
import 'package:intellimate/data/repositories/user_repository_impl.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/repositories/goal_repository.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';
import 'package:intellimate/domain/repositories/task_repository.dart';
import 'package:intellimate/domain/repositories/user_repository.dart';
import 'package:intellimate/domain/usecases/daily_note/create_daily_note.dart';
import 'package:intellimate/domain/usecases/daily_note/delete_daily_note.dart';
import 'package:intellimate/domain/usecases/daily_note/get_all_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_note_by_id.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_notes_by_condition.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_notes_with_code_snippets.dart';
import 'package:intellimate/domain/usecases/daily_note/get_private_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/search_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/update_daily_note.dart';
import 'package:intellimate/domain/usecases/note/create_note.dart';
import 'package:intellimate/domain/usecases/note/delete_note.dart';
import 'package:intellimate/domain/usecases/note/get_all_notes.dart';
import 'package:intellimate/domain/usecases/note/get_note_by_id.dart';
import 'package:intellimate/domain/usecases/note/search_notes.dart';
import 'package:intellimate/domain/usecases/note/update_note.dart';
import 'package:intellimate/domain/usecases/task/create_task_usecase.dart';
import 'package:intellimate/domain/usecases/task/delete_task_usecase.dart';
import 'package:intellimate/domain/usecases/task/get_all_tasks_usecase.dart';
import 'package:intellimate/domain/usecases/task/get_task_by_id_usecase.dart';
import 'package:intellimate/domain/usecases/task/get_tasks_by_condition_usecase.dart';
import 'package:intellimate/domain/usecases/task/update_task_usecase.dart';
import 'package:intellimate/presentation/providers/daily_note_provider.dart';
import 'package:intellimate/presentation/providers/goal_provider.dart';
import 'package:intellimate/presentation/providers/note_provider.dart';
import 'package:intellimate/presentation/providers/task_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 数据源
  sl.registerLazySingleton<GoalDataSource>(() => GoalDataSource());
  sl.registerLazySingleton<NoteDataSource>(() => NoteDataSourceImpl());
  sl.registerLazySingleton<TaskDataSource>(() => TaskDataSourceImpl());
  sl.registerLazySingleton<UserDataSource>(() => UserDataSource());
  sl.registerLazySingleton<DailyNoteDataSource>(() => DailyNoteDataSourceImpl());

  // 仓库
  sl.registerLazySingleton<GoalRepository>(() => GoalRepositoryImpl(sl<GoalDataSource>()));
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(dataSource: sl<NoteDataSource>()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(dataSource: sl<TaskDataSource>()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<UserDataSource>()),
  );
  sl.registerLazySingleton<DailyNoteRepository>(
    () => DailyNoteRepositoryImpl(sl<DailyNoteDataSource>()),
  );

  // 笔记用例
  sl.registerLazySingleton(() => GetAllNotes(sl<NoteRepository>()));
  sl.registerLazySingleton(() => GetNoteById(sl<NoteRepository>()));
  sl.registerLazySingleton(() => CreateNote(sl<NoteRepository>()));
  sl.registerLazySingleton(() => UpdateNote(sl<NoteRepository>()));
  sl.registerLazySingleton(() => DeleteNote(sl<NoteRepository>()));
  sl.registerLazySingleton(() => SearchNotes(sl<NoteRepository>()));

  // 任务用例
  sl.registerLazySingleton(() => GetAllTasksUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => GetTaskByIdUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => GetTasksByConditionUseCase(sl<TaskRepository>()));

  // 日常点滴用例
  sl.registerLazySingleton(() => GetAllDailyNotes(sl<DailyNoteRepository>()));
  sl.registerLazySingleton(() => GetDailyNoteById(sl<DailyNoteRepository>()));
  sl.registerLazySingleton(() => CreateDailyNote(sl<DailyNoteRepository>()));
  sl.registerLazySingleton(() => UpdateDailyNote(sl<DailyNoteRepository>()));
  sl.registerLazySingleton(() => DeleteDailyNote(sl<DailyNoteRepository>()));
  sl.registerLazySingleton(() => SearchDailyNotes(sl<DailyNoteRepository>()));
  sl.registerLazySingleton(() => GetDailyNotesByCondition(sl<DailyNoteRepository>()));
  sl.registerLazySingleton(() => GetPrivateDailyNotes(sl<DailyNoteRepository>()));
  sl.registerLazySingleton(() => GetDailyNotesWithCodeSnippets(sl<DailyNoteRepository>()));

  // Provider
  sl.registerFactory(() => GoalProvider(sl<GoalRepository>()));
  sl.registerFactory(() => NoteProvider(
    getAllNotes: sl<GetAllNotes>(),
    getNoteById: sl<GetNoteById>(),
    createNote: sl<CreateNote>(),
    updateNote: sl<UpdateNote>(),
    deleteNote: sl<DeleteNote>(),
    searchNotes: sl<SearchNotes>(),
  ));
  sl.registerFactory(() => TaskProvider(
    getAllTasksUseCase: sl<GetAllTasksUseCase>(),
    getTaskByIdUseCase: sl<GetTaskByIdUseCase>(),
    createTaskUseCase: sl<CreateTaskUseCase>(),
    updateTaskUseCase: sl<UpdateTaskUseCase>(),
    deleteTaskUseCase: sl<DeleteTaskUseCase>(),
    getTasksByConditionUseCase: sl<GetTasksByConditionUseCase>(),
  ));
  sl.registerFactory(() => DailyNoteProvider(
    createDailyNoteUseCase: sl<CreateDailyNote>(),
    deleteDailyNoteUseCase: sl<DeleteDailyNote>(),
    getAllDailyNotesUseCase: sl<GetAllDailyNotes>(),
    getDailyNoteByIdUseCase: sl<GetDailyNoteById>(),
    getDailyNotesByConditionUseCase: sl<GetDailyNotesByCondition>(),
    getDailyNotesWithCodeSnippetsUseCase: sl<GetDailyNotesWithCodeSnippets>(),
    getPrivateDailyNotesUseCase: sl<GetPrivateDailyNotes>(),
    searchDailyNotesUseCase: sl<SearchDailyNotes>(),
    updateDailyNoteUseCase: sl<UpdateDailyNote>(),
  ));
}