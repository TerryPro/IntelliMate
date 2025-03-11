import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/finance.dart';
import 'package:intl/intl.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String _selectedFilter = '本月';
  
  // 模拟数据 - 财务列表
  final List<Finance> _finances = [
    Finance(
      id: '1',
      amount: 68.0,
      type: 'expense',
      category: '餐饮',
      description: '午餐',
      date: DateTime.now(),
      paymentMethod: '现金',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Finance(
      id: '2',
      amount: 8500.0,
      type: 'income',
      category: '工资',
      description: '工资',
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: '银行卡',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Finance(
      id: '3',
      amount: 235.5,
      type: 'expense',
      category: '购物',
      description: '超市购物',
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: '支付宝',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Finance(
      id: '4',
      amount: 45.0,
      type: 'expense',
      category: '交通',
      description: '打车',
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: '微信',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
  
  // 时间筛选选项
  final List<String> _filters = ['本月', '上月', '本季度', '本年', '自定义'];
  
  // 添加新的财务记录
  void _addFinance() {
    Navigator.pushNamed(context, AppRoutes.addFinance);
  }
  
  // 计算总收入
  double get _totalIncome {
    return _finances
        .where((finance) => finance.type == 'income')
        .fold(0, (sum, finance) => sum + finance.amount);
  }
  
  // 计算总支出
  double get _totalExpense {
    return _finances
        .where((finance) => finance.type == 'expense')
        .fold(0, (sum, finance) => sum + finance.amount);
  }
  
  // 计算预算使用百分比
  double get _budgetUsagePercentage {
    // 假设预算为8500
    const budget = 8500.0;
    return (_totalExpense / budget) * 100;
  }
  
  // 计算剩余预算
  double get _remainingBudget {
    const budget = 8500.0;
    return budget - _totalExpense;
  }
  
  // 获取支出分类统计
  Map<String, double> get _expenseByCategory {
    final result = <String, double>{};
    
    for (final finance in _finances) {
      if (finance.type == 'expense') {
        if (result.containsKey(finance.category)) {
          result[finance.category] = result[finance.category]! + finance.amount;
        } else {
          result[finance.category] = finance.amount;
        }
      }
    }
    
    return result;
  }
  
  // 计算分类支出占比
  double _getCategoryPercentage(String category) {
    final categoryAmount = _expenseByCategory[category] ?? 0;
    return (categoryAmount / _totalExpense) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 自定义顶部导航栏
          _buildCustomAppBar(),
          
          // 主体内容
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 财务概览
                    _buildFinanceOverview(),
                    
                    // 时间筛选
                    _buildTimeFilter(),
                    
                    // 收支分析
                    _buildFinanceAnalysis(),
                    
                    // 最近交易
                    _buildRecentTransactions(),
                    
                    // 预算管理
                    _buildBudgetManagement(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 新增财务记录浮动按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _addFinance,
        backgroundColor: const Color(0xFF3ECABB),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  // 构建自定义顶部导航栏
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '财务管理',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: _addFinance,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackWithOpacity10,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建财务概览
  Widget _buildFinanceOverview() {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 2);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本月概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '收入',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(_totalIncome),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '支出',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(_totalExpense),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 预算进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _budgetUsagePercentage / 100,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3ECABB)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '预算使用: ${_budgetUsagePercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '剩余: ${currencyFormat.format(_remainingBudget)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建时间筛选
  Widget _buildTimeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 20),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3ECABB) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // 构建收支分析
  Widget _buildFinanceAnalysis() {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 2);
    final expenseCategories = _expenseByCategory.keys.toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '收支分析',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 查看详情
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.pie_chart,
                      color: Color(0xFF3ECABB),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '详情',
                      style: TextStyle(
                        color: Color(0xFF3ECABB),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 图表占位
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '收支分析图表',
                style: TextStyle(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 分类统计
          Row(
            children: expenseCategories.take(3).map((category) {
              final amount = _expenseByCategory[category] ?? 0;
              final percentage = _getCategoryPercentage(category);
              
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(amount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  // 构建最近交易
  Widget _buildRecentTransactions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近交易',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // 查看全部交易
              },
              child: const Text(
                '查看全部',
                style: TextStyle(
                  color: Color(0xFF3ECABB),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: _finances.map((finance) => _buildTransactionItem(finance)).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  // 构建交易项
  Widget _buildTransactionItem(Finance finance) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 2);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MM-dd');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final financeDate = DateTime(finance.date.year, finance.date.month, finance.date.day);
    
    String dateText;
    if (financeDate == today) {
      dateText = '今天 ${timeFormat.format(finance.date)}';
    } else if (financeDate == yesterday) {
      dateText = '昨天 ${timeFormat.format(finance.date)}';
    } else {
      dateText = '${dateFormat.format(finance.date)} ${timeFormat.format(finance.date)}';
    }
    
    IconData categoryIcon;
    Color categoryColor;
    
    switch (finance.category) {
      case '餐饮':
        categoryIcon = Icons.restaurant;
        categoryColor = Colors.red;
        break;
      case '工资':
        categoryIcon = Icons.attach_money;
        categoryColor = Colors.green;
        break;
      case '购物':
        categoryIcon = Icons.shopping_bag;
        categoryColor = Colors.red;
        break;
      case '交通':
        categoryIcon = Icons.directions_car;
        categoryColor = Colors.red;
        break;
      default:
        categoryIcon = Icons.category;
        categoryColor = Colors.blue;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // ignore: prefer_const_literals_to_create_immutables
        boxShadow: [
          const BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 分类图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: finance.type == 'income' 
                  ? Colors.green.shade100 
                  : Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // 描述和日期
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finance.description ?? finance.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // 金额
          Text(
            finance.type == 'income' 
                ? '+${currencyFormat.format(finance.amount)}' 
                : '-${currencyFormat.format(finance.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: finance.type == 'income' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建预算管理
  Widget _buildBudgetManagement() {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 0);
    
    // 预算数据
    final budgets = [
      {
        'category': '餐饮',
        'icon': Icons.restaurant,
        'color': Colors.red,
        'current': 1850.0,
        'total': 2000.0,
      },
      {
        'category': '交通',
        'icon': Icons.directions_car,
        'color': Colors.blue,
        'current': 920.5,
        'total': 1500.0,
      },
      {
        'category': '购物',
        'icon': Icons.shopping_bag,
        'color': Colors.purple,
        'current': 1250.0,
        'total': 2000.0,
      },
    ];
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '预算管理',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // 设置预算
              },
              child: const Text(
                '设置',
                style: TextStyle(
                  color: Color(0xFF3ECABB),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: budgets.map((budget) {
            final category = budget['category'] as String;
            final icon = budget['icon'] as IconData;
            final color = budget['color'] as Color;
            final current = budget['current'] as double;
            final total = budget['total'] as double;
            final percentage = (current / total) * 100;
            final isWarning = percentage > 90;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.blackWithOpacity05,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.getColorWithOpacity(color, 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${currencyFormat.format(current)} / ${currencyFormat.format(total)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: current / total,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isWarning ? Colors.red : color,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${percentage.toStringAsFixed(1)}% 已使用',
                      style: TextStyle(
                        fontSize: 12,
                        color: isWarning ? Colors.red : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 