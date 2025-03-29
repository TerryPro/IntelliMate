import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'memo_statistics.dart';
import 'memo_item.dart';
import 'package:intellimate/domain/core/memo_config.dart'; // 引入 MemoConfig 和 MemoCategory

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  bool _isLoading = true;
  List<Memo> _allMemos = [];
  List<Memo> _memos = [];
  MemoCategory _selectedCategory = MemoCategory.all; // 使用 MemoCategory 枚举

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMemos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      List<Memo> memos;

      _allMemos = await memoProvider.getAllMemos();

      if (_selectedCategory == MemoCategory.all) {
        memos = _allMemos;
      } else {
        memos = await memoProvider.getMemosByCategory(_selectedCategory.name);
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

  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = MemoCategory.values.firstWhere(
        (e) => e.name == categoryName,
        orElse: () => MemoCategory.all,
      );
    });
    _loadMemos();
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

  // 构建备忘录统计
  Widget _buildMemoStats() {
    return MemoStatistics(
      memos: _allMemos,
      onCategorySelected: _onCategorySelected, // 添加筛选回调
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
          ],
        ),
      ),
    );
  }

  // 构建备忘录项
  Widget _buildMemoItem(Memo memo) {
    return MemoItem(
      memo: memo,
      onEdit: _navigateToEditMemo,
      onDelete: _showDeleteConfirmation,
    );
  }

  // 显示删除确认对话框
  Future<void> _showDeleteConfirmation(String id) async {
    // 获取当前备忘录内容以便在预览中显示
    final memo = _memos.firstWhere((m) => m.id == id);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              '确认删除',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '你确定要删除这条备忘录吗？',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '此操作不可恢复，备忘录内容将永久删除。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '备忘录内容预览：',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memo.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (memo.content != null && memo.content!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      memo.content!,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              '确认删除',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }
    try {
      if (mounted) {
        final memoProvider = Provider.of<MemoProvider>(context, listen: false);
        final success = await memoProvider.deleteMemo(id);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('备忘录已删除'),
                backgroundColor: AppColors.primary,
              ),
            );
            _loadMemos();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('删除失败，请重试'),
                backgroundColor: Colors.red.shade400,
              ),
            );
          }
        }
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
