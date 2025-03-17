import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  bool _isLoading = true;
  List<Memo> _memos = [];
  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '工作', '学习', '生活', '健康', '其他'];
  final TextEditingController _searchController = TextEditingController();
  final bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      List<Memo> memos;

      if (_selectedCategory == '全部') {
        memos = await memoProvider.getAllMemos();
      } else {
        memos = await memoProvider.getMemosByCategory(_selectedCategory);
      }

      setState(() {
        _memos = memos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载备忘录失败: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _searchMemos(String query) async {
    if (query.trim().isEmpty) {
      _loadMemos();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      final memos = await memoProvider.searchMemos(query);

      setState(() {
        _memos = memos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索备忘录失败: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToAddMemo() async {
    final result = await Navigator.pushNamed(context, AppRoutes.editMemo);
    if (result == true) {
      _loadMemos();
    }
  }

  void _navigateToEditMemo(String id) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editMemo,
      arguments: id,
    );
    if (result == true) {
      _loadMemos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              // 使用统一的顶部导航栏
              UnifiedAppBar(
                title: '备忘管理',
                actions: [
                  AppBarRefreshButton(
                    onTap: _loadMemos,
                  ),
                  const SizedBox(width: 8),
                  AppBarAddButton(
                    onTap: _navigateToAddMemo,
                  ),
                ],
              ),

              // 主体内容
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMemos,
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 搜索框
                              _buildSearchBar(),
                              const SizedBox(height: 16),

                              // 分类过滤器
                              _buildCategoryFilter(),
                              const SizedBox(height: 20),

                              // 备忘录统计
                              _buildMemoStats(),
                              const SizedBox(height: 20),

                              // 备忘录列表
                              _memos.isEmpty
                                  ? _buildEmptyState()
                                  : Column(
                                      children: _memos
                                          .map((memo) => _buildMemoItem(memo))
                                          .toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索备忘录...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _isSearching
              ? const IconButton(
                  icon: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: null,
                )
              : (_searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _loadMemos();
                      },
                    )
                  : null),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        style: const TextStyle(fontSize: 14),
        onSubmitted: (value) {
          _searchMemos(value);
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }

  // 构建分类过滤器
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _categories.map((category) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 构建备忘录统计
  Widget _buildMemoStats() {
    // 计算各类别的备忘录数量
    int workCount = 0;
    int studyCount = 0;
    int lifeCount = 0;

    for (var memo in _memos) {
      switch (memo.category) {
        case '工作':
          workCount++;
          break;
        case '学习':
          studyCount++;
          break;
        case '生活':
          lifeCount++;
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  count: _memos.length,
                  label: '总备忘',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  count: workCount,
                  label: '工作',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  count: studyCount,
                  label: '学习',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  count: lifeCount,
                  label: '生活',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建统计项
  Widget _buildStatItem(
      {required int count, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 构建空状态
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '没有备忘录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击添加按钮创建新的备忘录',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddMemo,
              icon: const Icon(Icons.add),
              label: const Text('添加备忘录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建备忘录项
  Widget _buildMemoItem(Memo memo) {
    final categoryColor = _getCategoryColor(memo.category ?? '其他');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToEditMemo(memo.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和类别
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        memo.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        memo.category ?? '其他',
                        style: TextStyle(
                          fontSize: 12,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 内容预览
                Text(
                  memo.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // 底部信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 创建时间
                    Text(
                      '创建于: ${_formatDate(memo.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    // 操作按钮
                    Row(
                      children: [
                        // 编辑按钮
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () => _navigateToEditMemo(memo.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: '编辑',
                        ),
                        const SizedBox(width: 16),

                        // 删除按钮
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () => _showDeleteConfirmation(memo.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: '删除',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 获取类别颜色
  Color _getCategoryColor(String category) {
    switch (category) {
      case '工作':
        return Colors.blue;
      case '学习':
        return Colors.purple;
      case '生活':
        return Colors.green;
      case '健康':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 显示删除确认对话框
  Future<void> _showDeleteConfirmation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条备忘录吗？此操作不可恢复。'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      final success = await memoProvider.deleteMemo(id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备忘录已删除'),
            backgroundColor: AppColors.primary,
          ),
        );
        _loadMemos();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('删除失败，请重试'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }
}
