import 'package:get_it/get_it.dart';
import 'package:intellimate/data/datasources/memo_datasource.dart';
import 'package:intellimate/data/repositories/memo_repository_impl.dart';
import 'package:intellimate/domain/repositories/memo_repository.dart';
import 'package:intellimate/domain/usecases/memo/create_memo.dart';
import 'package:intellimate/domain/usecases/memo/delete_memo.dart';
import 'package:intellimate/domain/usecases/memo/get_all_memos.dart';
import 'package:intellimate/domain/usecases/memo/get_completed_memos.dart';
import 'package:intellimate/domain/usecases/memo/get_memo_by_id.dart';
import 'package:intellimate/domain/usecases/memo/get_memos_by_category.dart';
import 'package:intellimate/domain/usecases/memo/get_memos_by_date.dart';
import 'package:intellimate/domain/usecases/memo/get_memos_by_priority.dart';
import 'package:intellimate/domain/usecases/memo/get_pinned_memos.dart';
import 'package:intellimate/domain/usecases/memo/get_uncompleted_memos.dart';
import 'package:intellimate/domain/usecases/memo/search_memos.dart';
import 'package:intellimate/domain/usecases/memo/update_memo.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';

// 获取全局服务定位器实例
final GetIt sl = GetIt.instance;

// 注册备忘相关的依赖
Future<void> setupMemoServiceLocator() async {
  // 数据源
  if (!sl.isRegistered<MemoDataSource>()) {
    sl.registerLazySingleton<MemoDataSource>(() => MemoDataSource());
  }

  // 仓库
  if (!sl.isRegistered<MemoRepository>()) {
    sl.registerLazySingleton<MemoRepository>(
      () => MemoRepositoryImpl(sl<MemoDataSource>()),
    );
  }

  // 备忘用例
  if (!sl.isRegistered<GetMemoById>()) {
    sl.registerLazySingleton(() => GetMemoById(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<CreateMemo>()) {
    sl.registerLazySingleton(() => CreateMemo(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<UpdateMemo>()) {
    sl.registerLazySingleton(() => UpdateMemo(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<DeleteMemo>()) {
    sl.registerLazySingleton(() => DeleteMemo(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<GetAllMemos>()) {
    sl.registerLazySingleton(() => GetAllMemos(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<GetMemosByDate>()) {
    sl.registerLazySingleton(() => GetMemosByDate(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<GetCompletedMemos>()) {
    sl.registerLazySingleton(() => GetCompletedMemos(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<GetUncompletedMemos>()) {
    sl.registerLazySingleton(() => GetUncompletedMemos(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<GetMemosByPriority>()) {
    sl.registerLazySingleton(() => GetMemosByPriority(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<GetPinnedMemos>()) {
    sl.registerLazySingleton(() => GetPinnedMemos(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<SearchMemos>()) {
    sl.registerLazySingleton(() => SearchMemos(sl<MemoRepository>()));
  }
  if (!sl.isRegistered<GetMemosByCategory>()) {
    sl.registerLazySingleton(() => GetMemosByCategory(sl<MemoRepository>()));
  }

  // Provider
  if (!sl.isRegistered<MemoProvider>()) {
    sl.registerFactory(() => MemoProvider(
      getMemoByIdUseCase: sl<GetMemoById>(),
      createMemoUseCase: sl<CreateMemo>(),
      updateMemoUseCase: sl<UpdateMemo>(),
      deleteMemoUseCase: sl<DeleteMemo>(),
      getAllMemosUseCase: sl<GetAllMemos>(),
      getMemosByDateUseCase: sl<GetMemosByDate>(),
      getCompletedMemosUseCase: sl<GetCompletedMemos>(),
      getUncompletedMemosUseCase: sl<GetUncompletedMemos>(),
      getMemosByPriorityUseCase: sl<GetMemosByPriority>(),
      getPinnedMemosUseCase: sl<GetPinnedMemos>(),
      searchMemosUseCase: sl<SearchMemos>(),
      getMemosByCategoryUseCase: sl<GetMemosByCategory>(),
    ));
  }
} 