import 'package:flutter/foundation.dart';
import 'package:intellimate/data/datasources/finance_datasource.dart';
import 'package:intellimate/data/repositories/finance_repository_impl.dart';
import 'package:intellimate/domain/entities/finance.dart';
import 'package:intellimate/domain/repositories/finance_repository.dart';

class FinanceProvider with ChangeNotifier {
  final FinanceRepository _repository;
  
  // 财务列表
  List<Finance> _finances = [];
  // 当前选中的时间过滤器
  String _selectedFilter = '本月';
  // 是否正在加载
  bool _isLoading = false;
  // 总收入
  double _totalIncome = 0;
  // 总支出
  double _totalExpense = 0;
  // 支出分类统计
  Map<String, double> _expenseByCategory = {};
  // 收入分类统计
  Map<String, double> _incomeByCategory = {};
  // 时间筛选选项
  final List<String> _filters = ['本月', '上月', '本季度', '本年', '自定义'];

  // 获取属性
  List<Finance> get finances => _finances;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  Map<String, double> get expenseByCategory => _expenseByCategory;
  Map<String, double> get incomeByCategory => _incomeByCategory;
  List<String> get filters => _filters;
  
  // 创建预设的预算值
  final double _budget = 8500.0;
  double get budget => _budget;
  
  // 计算预算使用百分比
  double get budgetUsagePercentage => (_totalExpense / _budget) * 100;
  
  // 计算剩余预算
  double get remainingBudget => _budget - _totalExpense;

  // 构造函数
  FinanceProvider() : _repository = FinanceRepositoryImpl(FinanceDataSource()) {
    // 初始化加载当月数据
    loadFinances();
  }

  // 设置选中的时间过滤器
  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    loadFinances();
    notifyListeners();
  }

  // 计算指定过滤器的时间范围
  (DateTime, DateTime) _getDateRangeForFilter(String filter) {
    final now = DateTime.now();
    final DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    switch (filter) {
      case '本月':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case '上月':
        final lastMonth = now.month == 1 
            ? DateTime(now.year - 1, 12, 1)
            : DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        // 上月的最后一天
        endDate = DateTime(
          now.month == 1 ? now.year - 1 : now.year,
          now.month == 1 ? 12 : now.month - 1,
          DateTime(
            now.month == 1 ? now.year - 1 : now.year,
            now.month == 1 ? 13 : now.month,
            0
          ).day,
          23,
          59,
          59
        );
        break;
      case '本季度':
        // 计算当前季度的开始月份
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        startDate = DateTime(now.year, quarterStartMonth, 1);
        break;
      case '本年':
        startDate = DateTime(now.year, 1, 1);
        break;
      case '自定义':
        // 默认显示最近30天
        startDate = now.subtract(const Duration(days: 30));
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }
    
    return (startDate, endDate);
  }

  // 根据时间过滤器加载财务数据
  Future<void> loadFinances() async {
    _setLoading(true);
    
    try {
      final (startDate, endDate) = _getDateRangeForFilter(_selectedFilter);
      
      // 加载指定日期范围内的财务记录
      _finances = await _repository.getFinancesByDateRange(startDate, endDate);
      
      // 加载总收入和总支出
      _totalIncome = await _repository.getTotalIncomeByDateRange(startDate, endDate);
      _totalExpense = await _repository.getTotalExpenseByDateRange(startDate, endDate);
      
      // 加载分类统计
      _expenseByCategory = await _repository.getExpenseStatsByCategory(startDate, endDate);
      _incomeByCategory = await _repository.getIncomeStatsByCategory(startDate, endDate);
      
      notifyListeners();
    } catch (e) {
      debugPrint('加载财务数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 添加财务记录
  Future<void> addFinance(Finance finance) async {
    _setLoading(true);
    
    try {
      await _repository.createFinance(finance);
      // 刷新数据
      await loadFinances();
    } catch (e) {
      debugPrint('添加财务记录失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 更新财务记录
  Future<void> updateFinance(Finance finance) async {
    _setLoading(true);
    
    try {
      await _repository.updateFinance(finance);
      // 刷新数据
      await loadFinances();
    } catch (e) {
      debugPrint('更新财务记录失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 删除财务记录
  Future<void> deleteFinance(String id) async {
    _setLoading(true);
    
    try {
      await _repository.deleteFinance(id);
      // 刷新数据
      await loadFinances();
    } catch (e) {
      debugPrint('删除财务记录失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 