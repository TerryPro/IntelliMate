import 'package:intellimate/domain/entities/memo.dart';

abstract class MemoRepository {
  // 获取单个备忘
  Future<Memo?> getMemoById(String id);
  
  // 创建备忘
  Future<Memo> createMemo({
    required String title,
    required String content,
    String? category,
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
  
  // 搜索备忘
  Future<List<Memo>> searchMemos(String query);
  
  // 按类别获取备忘
  Future<List<Memo>> getMemosByCategory(String category);
} 