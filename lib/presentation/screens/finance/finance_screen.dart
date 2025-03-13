import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/finance.dart';
import 'package:intellimate/presentation/providers/finance_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  @override
  void initState() {
    super.initState();
    // 当界面初始化时加载财务数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadFinances();
    });
  }
  
  // 添加新的财务记录
  void _addFinance() {
    Navigator.pushNamed(context, AppRoutes.addFinance).then((value) {
      if (value != null && value is Finance) {
        // 如果返回了新创建的财务记录，则添加到数据库
        context.read<FinanceProvider>().addFinance(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用Consumer监听FinanceProvider状态变化
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              // 自定义顶部导航栏
              _buildCustomAppBar(),
              
              // 主体内容
              Expanded(
                child: financeProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // 财务概览
                              _buildFinanceOverview(financeProvider),
                              
                              // 时间筛选
                              _buildTimeFilter(financeProvider),
                              
                              // 收支分析
                              _buildFinanceAnalysis(financeProvider),
                              
                              // 最近交易
                              _buildRecentTransactions(financeProvider),
                              
                              // 预算管理
                              _buildBudgetManagement(financeProvider),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      }
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
        color: Color(0xFF3ECABB),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.home);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '财务管理',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // 刷新财务数据
                  context.read<FinanceProvider>().loadFinances();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF3ECABB),
                    size: 20,
                  ),
                  onPressed: _addFinance,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建财务概览
  Widget _buildFinanceOverview(FinanceProvider provider) {
    // 格式化金额
    final NumberFormat formatter = NumberFormat("#,##0.00", "zh_CN");
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3ECABB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                '本月余额',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                provider.selectedFilter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '¥ ${formatter.format(provider.totalIncome - provider.totalExpense)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '收入',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥ ${formatter.format(provider.totalIncome)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '支出',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥ ${formatter.format(provider.totalExpense)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '预算',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥ ${formatter.format(provider.budget)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建时间筛选
  Widget _buildTimeFilter(FinanceProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: provider.filters.map((filter) {
            final isSelected = filter == provider.selectedFilter;
            
            return GestureDetector(
              onTap: () {
                provider.setSelectedFilter(filter);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3ECABB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  // 构建财务分析
  Widget _buildFinanceAnalysis(FinanceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '支出分类',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          if (provider.expenseByCategory.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '暂无支出数据',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...provider.expenseByCategory.entries.map((entry) {
              final categoryPercentage = (entry.value / provider.totalExpense) * 100;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '${categoryPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: categoryPercentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(entry.key),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
  
  // 为不同的分类返回不同的颜色
  Color _getCategoryColor(String category) {
    switch (category) {
      case '餐饮':
        return Colors.red;
      case '交通':
        return Colors.blue;
      case '购物':
        return Colors.purple;
      case '娱乐':
        return Colors.indigo;
      case '住房':
        return Colors.amber;
      case '医疗':
        return Colors.green;
      case '教育':
        return Colors.teal;
      case '服饰':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
  
  // 构建最近交易
  Widget _buildRecentTransactions(FinanceProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近交易',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          if (provider.finances.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '暂无交易记录',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...provider.finances.map((finance) => _buildTransactionItem(finance)),
        ],
      ),
    );
  }
  
  // 构建交易项
  Widget _buildTransactionItem(Finance finance) {
    // 格式化日期
    final date = DateFormat('MM-dd').format(finance.date);
    // 格式化金额
    final amount = NumberFormat("#,##0.00", "zh_CN").format(finance.amount);
    
    // 获取图标和颜色
    IconData icon;
    Color iconColor;
    
    switch (finance.category) {
      case '餐饮':
        icon = Icons.restaurant;
        iconColor = Colors.red;
        break;
      case '交通':
        icon = Icons.directions_car;
        iconColor = Colors.blue;
        break;
      case '购物':
        icon = Icons.shopping_bag;
        iconColor = Colors.purple;
        break;
      case '娱乐':
        icon = Icons.sports_esports;
        iconColor = Colors.indigo;
        break;
      case '住房':
        icon = Icons.home;
        iconColor = Colors.amber;
        break;
      case '医疗':
        icon = Icons.favorite;
        iconColor = Colors.green;
        break;
      case '教育':
        icon = Icons.school;
        iconColor = Colors.teal;
        break;
      case '工资':
        icon = Icons.attach_money;
        iconColor = Colors.green;
        break;
      case '投资':
        icon = Icons.trending_up;
        iconColor = Colors.blue;
        break;
      case '服饰':
        icon = Icons.checkroom;
        iconColor = Colors.pink;
        break;
      default:
        icon = Icons.more_horiz;
        iconColor = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 类别图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // 交易信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finance.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (finance.description != null)
                  Text(
                    finance.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
          // 金额和日期
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                finance.type == 'expense' ? '- ¥$amount' : '+ ¥$amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: finance.type == 'expense' ? Colors.red : Colors.green,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建预算管理
  Widget _buildBudgetManagement(FinanceProvider provider) {
    // 格式化金额
    final formatter = NumberFormat("#,##0.00", "zh_CN");
    final budgetPercentage = provider.budgetUsagePercentage.clamp(0.0, 100.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '预算管理',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: budgetPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              budgetPercentage > 80 ? Colors.red : const Color(0xFF3ECABB),
            ),
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已用: ¥${formatter.format(provider.totalExpense)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '剩余: ¥${formatter.format(provider.remainingBudget)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                budgetPercentage > 80
                    ? '您的支出已接近预算上限，请注意控制开支'
                    : '您的预算使用情况良好，继续保持',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 