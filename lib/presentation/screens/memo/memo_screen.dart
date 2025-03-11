import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intl/intl.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  String _selectedFilter = '全部';
  
  // 模拟数据 - 备忘录列表
  final List<Memo> _memos = [
    Memo(
      id: '1',
      title: '项目会议',
      content: '讨论新版本功能规划和开发计划',
      date: DateTime.now().add(const Duration(days: 1)),
      category: '工作',
      priority: '重要',
      isPinned: true,
      isCompleted: false,
      completedAt: null,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Memo(
      id: '2',
      title: '购买生日礼物',
      content: '为妈妈挑选生日礼物，考虑买一条围巾或者一个包',
      date: DateTime.now().add(const Duration(days: 3)),
      category: '个人',
      priority: '提醒',
      isPinned: true,
      isCompleted: false,
      completedAt: null,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Memo(
      id: '3',
      title: '健身计划',
      content: '每周三次健身，包括有氧运动和力量训练',
      date: DateTime.now().add(const Duration(days: 1)),
      category: '健康',
      priority: '一般',
      isPinned: false,
      isCompleted: false,
      completedAt: null,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Memo(
      id: '4',
      title: '缴纳水电费',
      content: '本月水电费需要在25日前缴纳',
      date: DateTime.now().add(const Duration(days: 5)),
      category: '生活',
      priority: '提醒',
      isPinned: false,
      isCompleted: false,
      completedAt: null,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Memo(
      id: '5',
      title: '预约牙医',
      content: '牙齿检查和洁牙',
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: '健康',
      priority: '重要',
      isPinned: false,
      isCompleted: true,
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Memo(
      id: '6',
      title: '提交工作报告',
      content: '整理本周工作内容，提交周报',
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: '工作',
      priority: '重要',
      isPinned: false,
      isCompleted: true,
      completedAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
  
  // 筛选选项
  final List<String> _filters = ['全部', '重要', '提醒', '一般'];
  
  // 添加新备忘录
  void _addMemo() {
    Navigator.pushNamed(context, AppRoutes.addMemo).then((result) {
      if (result != null && result is Memo) {
        setState(() {
          // 查找是否存在相同ID的备忘录
          final index = _memos.indexWhere((memo) => memo.id == result.id);
          if (index != -1) {
            // 更新现有备忘录
            _memos[index] = result;
          } else {
            // 添加新备忘录
            _memos.add(result);
          }
        });
      }
    });
  }
  
  // 切换备忘录完成状态
  void _toggleMemoCompleted(String memoId) {
    setState(() {
      final index = _memos.indexWhere((memo) => memo.id == memoId);
      if (index != -1) {
        final memo = _memos[index];
        _memos[index] = Memo(
          id: memo.id,
          title: memo.title,
          content: memo.content,
          date: memo.date,
          category: memo.category,
          priority: memo.priority,
          isPinned: memo.isPinned,
          isCompleted: !memo.isCompleted,
          completedAt: !memo.isCompleted ? DateTime.now() : null,
          createdAt: memo.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
  }
  
  // 切换备忘录置顶状态
  void _toggleMemoPinned(String memoId) {
    setState(() {
      final index = _memos.indexWhere((memo) => memo.id == memoId);
      if (index != -1) {
        final memo = _memos[index];
        _memos[index] = Memo(
          id: memo.id,
          title: memo.title,
          content: memo.content,
          date: memo.date,
          category: memo.category,
          priority: memo.priority,
          isPinned: !memo.isPinned,
          isCompleted: memo.isCompleted,
          completedAt: memo.completedAt,
          createdAt: memo.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
  }
  
  // 获取备忘录总数
  int get _totalMemos => _memos.length;
  
  // 获取重要备忘录数量
  int get _importantMemos => _memos.where((memo) => memo.priority == '重要').length;
  
  // 获取已完成备忘录数量
  int get _completedMemos => _memos.where((memo) => memo.isCompleted).length;
  
  // 获取置顶备忘录
  List<Memo> get _pinnedMemos => _memos.where((memo) => memo.isPinned && !memo.isCompleted).toList();
  
  // 获取最近备忘录（未完成且未置顶）
  List<Memo> get _recentMemos => _memos.where((memo) => !memo.isPinned && !memo.isCompleted).toList();
  
  // 获取已完成备忘录
  List<Memo> get _completedMemosList => _memos.where((memo) => memo.isCompleted).toList();
  
  // 根据筛选获取备忘录
  List<Memo> _getFilteredMemos(List<Memo> memos) {
    if (_selectedFilter == '全部') {
      return memos;
    } else {
      return memos.where((memo) => memo.priority == _selectedFilter).toList();
    }
  }

  // 编辑备忘录
  void _editMemo(Memo memo) {
    Navigator.pushNamed(
      context,
      AppRoutes.addMemo,
      arguments: memo,
    ).then((result) {
      if (result != null && result is Memo) {
        setState(() {
          final index = _memos.indexWhere((m) => m.id == result.id);
          if (index != -1) {
            _memos[index] = result;
          }
        });
      }
    });
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
                    // 备忘录统计
                    _buildMemoStats(),
                    
                    // 筛选选项
                    _buildFilterOptions(),
                    
                    // 置顶备忘
                    _buildPinnedMemos(),
                    
                    // 最近备忘
                    _buildRecentMemos(),
                    
                    // 已完成备忘
                    _buildCompletedMemos(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 新增备忘录浮动按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
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
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '备忘录',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _addMemo,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.whiteWithOpacity20,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建备忘录统计
  Widget _buildMemoStats() {
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
            '备忘录统计',
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
                child: _buildStatItem(
                  icon: Icons.sticky_note_2,
                  iconColor: const Color(0xFF3ECABB),
                  iconBgColor: const Color(0xFFEEFBFA),
                  title: '总备忘录',
                  count: _totalMemos,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.priority_high,
                  iconColor: Colors.red,
                  iconBgColor: Colors.red.shade50,
                  title: '重要事项',
                  count: _importantMemos,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  iconBgColor: Colors.green.shade50,
                  title: '已完成',
                  count: _completedMemos,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required int count,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
  
  // 构建筛选选项
  Widget _buildFilterOptions() {
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
  
  // 构建置顶备忘
  Widget _buildPinnedMemos() {
    final filteredMemos = _getFilteredMemos(_pinnedMemos);
    
    if (filteredMemos.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '置顶备忘',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${filteredMemos.length}项',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: filteredMemos.map((memo) => _buildMemoItem(memo)).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  // 构建最近备忘
  Widget _buildRecentMemos() {
    final filteredMemos = _getFilteredMemos(_recentMemos);
    
    if (filteredMemos.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近备忘',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${filteredMemos.length}项',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: filteredMemos.map((memo) => _buildMemoItem(memo)).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  // 构建已完成备忘
  Widget _buildCompletedMemos() {
    final filteredMemos = _getFilteredMemos(_completedMemosList);
    
    if (filteredMemos.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '已完成',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${filteredMemos.length}项',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: filteredMemos.map((memo) => _buildMemoItem(memo)).toList(),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
  
  // 构建备忘录项
  Widget _buildMemoItem(Memo memo) {
    final dateFormat = DateFormat('MM月dd日');
    final timeFormat = DateFormat('HH:mm');
    
    // 优先级颜色
    Color priorityColor;
    Color priorityBgColor;
    
    switch (memo.priority) {
      case '重要':
        priorityColor = Colors.red;
        priorityBgColor = Colors.red.shade50;
        break;
      case '提醒':
        priorityColor = Colors.amber;
        priorityBgColor = Colors.amber.shade50;
        break;
      default:
        priorityColor = Colors.blue;
        priorityBgColor = Colors.blue.shade50;
    }
    
    // 日期文本
    String dateText = '${dateFormat.format(memo.date)} ${timeFormat.format(memo.date)}';
    
    // 判断日期是否已过期
    final isOverdue = !memo.isCompleted && memo.date.isBefore(DateTime.now());
    
    return GestureDetector(
      onTap: () => _editMemo(memo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _toggleMemoCompleted(memo.id),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: memo.isCompleted ? const Color(0xFF3ECABB) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: memo.isCompleted ? const Color(0xFF3ECABB) : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: memo.isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              memo.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: memo.isCompleted ? Colors.grey.shade400 : Colors.black87,
                                fontSize: 16,
                                decoration: memo.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: priorityBgColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    memo.priority,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: priorityColor,
                                    ),
                                  ),
                                ),
                                if (memo.category != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      memo.category!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleMemoPinned(memo.id),
                  child: Icon(
                    memo.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: memo.isPinned ? const Color(0xFF3ECABB) : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memo.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: memo.isCompleted ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.5,
                      decoration: memo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: isOverdue ? Colors.red : Colors.grey.shade400,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey.shade500,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '已过期',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 