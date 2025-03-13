import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:intellimate/presentation/widgets/common/empty_state.dart';
import 'package:intellimate/presentation/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '工作', '生活', '学习', '健康'];
  bool _isLoading = false;

  // 备忘统计数据
  Map<String, int> _memoStats = {
    'total': 0,
    'important': 0,
    'completed': 0,
  };

  // 备忘数据
  List<Memo> _pinnedMemos = [];
  List<Memo> _recentMemos = [];
  List<Memo> _completedMemos = [];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      
      // 加载备忘数据
      if (_selectedCategory == '全部') {
        await memoProvider.getAllMemos();
      } else {
        await memoProvider.getMemosByCategory(_selectedCategory);
      }

      // 获取置顶备忘
      _pinnedMemos = await memoProvider.getPinnedMemos();
      
      // 获取最近备忘（未完成且未置顶的备忘）
      final allMemos = await memoProvider.getAllMemos(orderBy: 'updated_at', descending: true);
      _recentMemos = allMemos
          .where((memo) => !memo.isCompleted && !memo.isPinned)
          .take(5) // 只显示最近的5条
          .toList();
      
      // 获取已完成备忘
      _completedMemos = await memoProvider.getCompletedMemos();
      _completedMemos = _completedMemos.take(3).toList(); // 只显示最近的3条已完成备忘
      
      // 更新统计数据
      _updateMemoStats();
    } catch (e) {
      // 错误处理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载备忘录失败: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 更新备忘统计数据
  void _updateMemoStats() {
    final allMemos = [..._pinnedMemos, ..._recentMemos, ..._completedMemos];
    
    // 移除重复的备忘录
    final uniqueMemos = <String, Memo>{};
    for (var memo in allMemos) {
      uniqueMemos[memo.id] = memo;
    }
    
    // 计算统计数据
    final total = uniqueMemos.length;
    final important = uniqueMemos.values.where((memo) => memo.priority == '高').length;
    final completed = _completedMemos.length;
    
    setState(() {
      _memoStats = {
        'total': total,
        'important': important,
        'completed': completed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // bg-gray-50
      body: Column(
        children: [
         
          // 使用统一的顶部导航栏
          UnifiedAppBar(
            title: '备忘管理',
            actions: [
              AppBarAddButton(
                onTap: _navigateToAddMemo,
              ),
            ],
          ),
          
          // 内容区域
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 备忘统计
                          _buildMemoStats(),
                          
                          const SizedBox(height: 24),
                          
                          // 分类标签
                          _buildCategoryFilter(),
                          
                          const SizedBox(height: 20),
                          
                          // 置顶备忘
                          _buildPinnedMemos(),
                          
                          const SizedBox(height: 24),
                          
                          // 最近备忘
                          _buildRecentMemos(),
                          
                          const SizedBox(height: 24),
                          
                          // 已完成备忘
                          _buildCompletedMemos(),
                          
                          // 底部留白，确保浮动按钮不遮挡内容
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 构建备忘统计
  Widget _buildMemoStats() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备忘统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937), // text-gray-800
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: _memoStats['total']!,
                  label: '总备忘',
                  backgroundColor: const Color(0xFFD5F5F2), // primary-50
                  textColor: const Color(0xFF26B0A1), // primary-500
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  value: _memoStats['important']!,
                  label: '重要事项',
                  backgroundColor: const Color(0xFFFEF3C7), // yellow-50
                  textColor: const Color(0xFFEAB308), // yellow-500
                ),
              ),
              const SizedBox(width: 12),
          Expanded(
                child: _buildStatItem(
                  value: _memoStats['completed']!,
                  label: '已完成',
                  backgroundColor: const Color(0xFFDCFCE7), // green-50
                  textColor: const Color(0xFF22C55E), // green-500
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建单个统计项
  Widget _buildStatItem({
    required int value,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280), // text-gray-500
            ),
          ),
        ],
      ),
    );
  }

  // 构建分类过滤器
  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              _loadMemos();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF3ECABB) // primary-400
                    : const Color(0xFFE5E7EB), // gray-200
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : const Color(0xFF4B5563), // text-gray-600
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建置顶备忘
  Widget _buildPinnedMemos() {
    if (_pinnedMemos.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '置顶备忘',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // text-gray-800
              ),
            ),
            GestureDetector(
              onTap: () {
                // 管理置顶备忘
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('管理置顶备忘功能即将上线')),
                );
              },
              child: const Text(
                '管理',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3ECABB), // primary-400
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_pinnedMemos.length, (index) {
          final memo = _pinnedMemos[index];
          return _buildPinnedMemoItem(memo);
        }),
      ],
    );
  }
  
  // 构建置顶备忘项
  Widget _buildPinnedMemoItem(Memo memo) {
    // 决定背景颜色
    Color bgColor;
    Color borderColor;
    
    // 根据备忘的类别设置不同的颜色
    switch (memo.category) {
      case '工作':
        bgColor = const Color(0xFFFEF9C3); // yellow-50
        borderColor = const Color(0xFFFACC15); // yellow-400
        break;
      case '学习':
        bgColor = const Color(0xFFDEE9FD); // blue-50
        borderColor = const Color(0xFF60A5FA); // blue-400
        break;
      case '生活':
        bgColor = const Color(0xFFD5F5F2); // primary-50
        borderColor = const Color(0xFF3ECABB); // primary-400
        break;
      case '健康':
        bgColor = const Color(0xFFDCFCE7); // green-50
        borderColor = const Color(0xFF22C55E); // green-400
        break;
      default:
        bgColor = const Color(0xFFF3F4F6); // gray-100
        borderColor = const Color(0xFF9CA3AF); // gray-400
    }
    
    return GestureDetector(
      onTap: () => _navigateToEditMemo(memo.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    memo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937), // text-gray-800
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.thumbtack,
                      size: 14,
                      color: Color(0xFFEAB308), // yellow-500
                    ),
                    const SizedBox(width: 8),
                    _buildPriorityBadge(memo.priority),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              memo.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563), // text-gray-600
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.calendarAlt,
                      size: 12,
                      color: Color(0xFF6B7280), // text-gray-500
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(memo.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280), // text-gray-500
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.tag,
                      size: 12,
                      color: Color(0xFF3ECABB), // primary-500
                    ),
                    const SizedBox(width: 4),
                    Text(
                      memo.category ?? '未分类',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3ECABB), // primary-500
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建最近备忘
  Widget _buildRecentMemos() {
    if (_recentMemos.isEmpty) {
      return EmptyState(
        icon: FontAwesomeIcons.stickyNote,
        message: '没有最近备忘',
        subMessage: '点击添加按钮创建新的备忘录',
        action: ElevatedButton(
          onPressed: _navigateToAddMemo,
          child: const Text('添加备忘'),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近备忘',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // text-gray-800
              ),
            ),
            GestureDetector(
              onTap: () {
                // 查看全部最近备忘
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('查看全部功能即将上线')),
                );
              },
              child: const Text(
                '查看全部',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3ECABB), // primary-400
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_recentMemos.length, (index) {
          final memo = _recentMemos[index];
          return _buildRecentMemoItem(memo);
        }),
      ],
    );
  }
  
  // 构建最近备忘项
  Widget _buildRecentMemoItem(Memo memo) {
    return GestureDetector(
      onTap: () => _navigateToEditMemo(memo.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    memo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937), // text-gray-800
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildPriorityBadge(memo.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              memo.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563), // text-gray-600
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.calendarAlt,
                      size: 12,
                      color: Color(0xFF6B7280), // text-gray-500
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(memo.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280), // text-gray-500
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.tag,
                      size: 12,
                      color: Color(0xFF3ECABB), // primary-500
                    ),
                    const SizedBox(width: 4),
                    Text(
                      memo.category ?? '未分类',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3ECABB), // primary-500
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建已完成备忘
  Widget _buildCompletedMemos() {
    if (_completedMemos.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '已完成备忘',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // text-gray-800
              ),
            ),
            GestureDetector(
              onTap: () {
                // 查看全部已完成备忘
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('查看全部功能即将上线')),
                );
              },
              child: const Text(
                '查看全部',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3ECABB), // primary-400
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_completedMemos.length, (index) {
          final memo = _completedMemos[index];
          return _buildCompletedMemoItem(memo);
        }),
      ],
    );
  }
  
  // 构建已完成备忘项
  Widget _buildCompletedMemoItem(Memo memo) {
    return GestureDetector(
      onTap: () => _navigateToEditMemo(memo.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6), // gray-100
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Opacity(
          opacity: 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      memo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563), // text-gray-600
                        decoration: TextDecoration.lineThrough,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB), // gray-200
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '已完成',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280), // text-gray-500
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                memo.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280), // text-gray-500
                  decoration: TextDecoration.lineThrough,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.calendarAlt,
                        size: 12,
                        color: Color(0xFF6B7280), // text-gray-500
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(memo.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280), // text-gray-500
                        ),
                      ),
                    ],
                  ),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.checkCircle,
                          size: 12,
                          color: Color(0xFF6B7280), // text-gray-500
                        ),
                        const SizedBox(width: 4),
                        Text(
                          memo.completedAt != null 
                              ? _formatDate(memo.completedAt!) 
                              : '已完成',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280), // text-gray-500
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }

  // 构建优先级标签
  Widget _buildPriorityBadge(String priority) {
    Color bgColor;
    Color textColor;
    
    switch (priority) {
      case '高':
        bgColor = const Color(0xFFFEE2E2); // red-100
        textColor = const Color(0xFFDC2626); // red-600
        break;
      case '中':
        bgColor = const Color(0xFFFEF3C7); // yellow-100
        textColor = const Color(0xFFD97706); // yellow-600
        break;
      case '低':
        bgColor = const Color(0xFFDCFCE7); // green-100
        textColor = const Color(0xFF16A34A); // green-600
        break;
      default:
        bgColor = const Color(0xFFE5E7EB); // gray-100
        textColor = const Color(0xFF6B7280); // gray-500
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // 导航到添加备忘页面
  void _navigateToAddMemo() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addMemo);
    if (result == true) {
      _loadMemos();
    }
  }

  // 导航到编辑备忘页面
  void _navigateToEditMemo(String memoId) async {
    final result = await Navigator.pushNamed(
      context, 
      AppRoutes.editMemo,
      arguments: memoId,
    );
    if (result == true) {
      _loadMemos();
    }
  }

  // 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);
    
    if (dateToCompare.isAtSameMomentAs(today)) {
      return '今天 ${DateFormat('HH:mm').format(date)}';
    } else if (dateToCompare.isAtSameMomentAs(tomorrow)) {
      return '明天 ${DateFormat('HH:mm').format(date)}';
    } else if (dateToCompare.isAfter(today) && 
               dateToCompare.isBefore(today.add(const Duration(days: 7)))) {
      return DateFormat('E HH:mm').format(date); // 显示星期几
    } else {
      return DateFormat('MM月dd日').format(date);
    }
  }
} 