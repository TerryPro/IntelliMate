import 'package:intellimate/domain/entities/memo.dart';

abstract class MemoRepository {
  // 获取单个备忘
  Future<Memo?> getMemoById(String id);
  
  // 创建备忘
  Future<Memo> createMemo({
    required String title,
    required String content,
    required DateTime date,
    String? category,
    required String priority,
    required bool isPinned,
    required bool isCompleted,
    DateTime? completedAt,
  });
  
  // 更新备忘
  Future<bool> updateMemo(Memo memo);
  
  // 删除备忘
  Future<bool> deleteMemo(String id);
  
  // 获取所有备忘
  Future<List<Memo>> getAllMemos({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
  
  // 按日期获取备忘
  Future<List<Memo>> getMemosByDate(DateTime date);
  
  // 获取已完成的备忘
  Future<List<Memo>> getCompletedMemos();
  
  // 获取未完成的备忘
  Future<List<Memo>> getUncompletedMemos();
  
  // 按优先级获取备忘
  Future<List<Memo>> getMemosByPriority(String priority);
  
  // 获取置顶备忘
  Future<List<Memo>> getPinnedMemos();
  
  // 搜索备忘
  Future<List<Memo>> searchMemos(String query);
  
  // 按类别获取备忘
  Future<List<Memo>> getMemosByCategory(String category);
} 