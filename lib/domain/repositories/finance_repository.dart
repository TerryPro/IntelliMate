import 'package:intellimate/domain/entities/finance.dart';

abstract class FinanceRepository {
  /// 获取所有财务记录
  Future<List<Finance>> getAllFinances();
  
  /// 根据ID获取单个财务记录
  Future<Finance?> getFinanceById(String id);
  
  /// 创建财务记录
  Future<void> createFinance(Finance finance);
  
  /// 更新财务记录
  Future<void> updateFinance(Finance finance);
  
  /// 删除财务记录
  Future<void> deleteFinance(String id);
  
  /// 获取指定日期范围内的财务记录
  Future<List<Finance>> getFinancesByDateRange(DateTime startDate, DateTime endDate);
  
  /// 获取指定类型的财务记录（收入/支出）
  Future<List<Finance>> getFinancesByType(String type);
  
  /// 获取指定类别的财务记录
  Future<List<Finance>> getFinancesByCategory(String category);
  
  /// 获取指定时间范围和类型的财务记录
  Future<List<Finance>> getFinancesByDateRangeAndType(
    DateTime startDate, 
    DateTime endDate, 
    String type
  );
  
  /// 获取指定时间范围内的总收入
  Future<double> getTotalIncomeByDateRange(DateTime startDate, DateTime endDate);
  
  /// 获取指定时间范围内的总支出
  Future<double> getTotalExpenseByDateRange(DateTime startDate, DateTime endDate);
  
  /// 获取指定时间范围内按类别分组的支出统计
  Future<Map<String, double>> getExpenseStatsByCategory(
    DateTime startDate, 
    DateTime endDate
  );
  
  /// 获取指定时间范围内按类别分组的收入统计
  Future<Map<String, double>> getIncomeStatsByCategory(
    DateTime startDate, 
    DateTime endDate
  );
} 