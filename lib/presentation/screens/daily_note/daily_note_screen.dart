import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/presentation/providers/daily_note_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class DailyNoteScreen extends StatefulWidget {
  const DailyNoteScreen({super.key});

  @override
  State<DailyNoteScreen> createState() => _DailyNoteScreenState();
}

class _DailyNoteScreenState extends State<DailyNoteScreen> {
  String _selectedFilter = '全部';
  final TextEditingController _quickNoteController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  List<DailyNote> _displayedNotes = [];
  bool _hasMoreNotes = true;

  Map<String, int> _statistics = {
    'total': 0,
    'today': 0,
    'week': 0,
    'month': 0,
    'quarter': 0,
  };

  Future<void> _loadStatistics() async {
    final provider = Provider.of<DailyNoteProvider>(context, listen: false);
    final stats = await provider.getDailyNoteStatistics();
    if (mounted) {
      setState(() {
        _statistics = stats;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialDailyNotes();
    _loadStatistics();
  }

  // 加载初始日常点滴数据（今天、昨天、前天）
  Future<void> _loadInitialDailyNotes() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMoreNotes = true;
    });

    try {
      final provider = Provider.of<DailyNoteProvider>(context, listen: false);
      await provider.getAllDailyNotes();

      // 获取最近三天的点滴
      _displayedNotes = await provider.getRecentThreeDaysDailyNotes();
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载日常点滴失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 根据筛选条件加载日常点滴
  Future<void> _loadFilteredDailyNotes() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMoreNotes = true;
    });

    try {
      final provider = Provider.of<DailyNoteProvider>(context, listen: false);
      List<DailyNote> filteredNotes = [];

      switch (_selectedFilter) {
        case '全部':
          await provider.getAllDailyNotes();
          filteredNotes = provider.dailyNotes;
          break;
        case '今天':
          filteredNotes = await provider.getTodayDailyNotes();
          break;
        case '本周':
          filteredNotes = await provider.getThisWeekDailyNotes();
          break;
        case '本月':
          filteredNotes = await provider.getThisMonthDailyNotes();
          break;
        case '本季度':
          filteredNotes = await provider.getThisQuarterDailyNotes();
          break;
        default:
          await provider.getAllDailyNotes();
          filteredNotes = provider.dailyNotes;
      }

      _displayedNotes = filteredNotes;

      // 如果筛选后的记录数小于页面大小，则没有更多记录
      if (filteredNotes.length < _pageSize) {
        _hasMoreNotes = false;
      }
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载日常点滴失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 加载更多日常点滴
  Future<void> _loadMoreDailyNotes() async {
    if (_isLoadingMore || !_hasMoreNotes) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final provider = Provider.of<DailyNoteProvider>(context, listen: false);
      _currentPage++;

      List<DailyNote> moreNotes = [];
      final offset = _currentPage * _pageSize;

      switch (_selectedFilter) {
        case '全部':
          moreNotes = await provider.getDailyNotesByCondition(
            limit: _pageSize,
            offset: offset,
          );
          break;
        case '今天':
          final now = DateTime.now();
          final startOfDay = DateTime(now.year, now.month, now.day);
          final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

          moreNotes = await provider.getDailyNotesByCondition(
            fromDate: startOfDay,
            toDate: endOfDay,
            limit: _pageSize,
            offset: offset,
          );
          break;
        case '本周':
          final now = DateTime.now();
          final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final startOfWeek = DateTime(
              firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);

          moreNotes = await provider.getDailyNotesByCondition(
            fromDate: startOfWeek,
            toDate: now,
            limit: _pageSize,
            offset: offset,
          );
          break;
        case '本月':
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);

          moreNotes = await provider.getDailyNotesByCondition(
            fromDate: startOfMonth,
            toDate: now,
            limit: _pageSize,
            offset: offset,
          );
          break;
        case '本季度':
          final now = DateTime.now();
          final quarterFirstMonth = ((now.month - 1) ~/ 3) * 3 + 1;
          final startOfQuarter = DateTime(now.year, quarterFirstMonth, 1);

          moreNotes = await provider.getDailyNotesByCondition(
            fromDate: startOfQuarter,
            toDate: now,
            limit: _pageSize,
            offset: offset,
          );
          break;
        default:
          moreNotes = await provider.getDailyNotesByCondition(
            limit: _pageSize,
            offset: offset,
          );
      }

      if (moreNotes.isEmpty || moreNotes.length < _pageSize) {
        _hasMoreNotes = false;
      }

      _displayedNotes.addAll(moreNotes);
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载更多点滴失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _quickNoteController.dispose();
    super.dispose();
  }

  // 添加新的日常点滴
  void _addDailyNote() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addDailyNote);

    // 检查组件是否仍然挂载
    if (!mounted) return;

    if (result == true) {
      _loadFilteredDailyNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('点滴已发布'),
          backgroundColor: Color(0xFF3ECABB),
        ),
      );
    }
  }

  // 添加快速笔记
  Future<void> _addQuickNote() async {
    if (_quickNoteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<DailyNoteProvider>(context, listen: false)
          .createDailyNote(
        content: _quickNoteController.text.trim(),
        isPrivate: false,
      );

      _quickNoteController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('点滴已发布'),
            backgroundColor: Color(0xFF3ECABB),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 使用统一的顶部导航栏
          UnifiedAppBar(
            title: '日常点滴',
            actions: [
              AppBarRefreshButton(
                onTap: _loadFilteredDailyNotes,
              ),
              const SizedBox(width: 8),
              AppBarAddButton(
                onTap: _addDailyNote,
              ),
            ],
          ),

          // 主体内容
          Expanded(
            child: Consumer<DailyNoteProvider>(
              builder: (context, dailyNoteProvider, child) {
                if (_isLoading || dailyNoteProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (dailyNoteProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '加载失败: ${dailyNoteProvider.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadFilteredDailyNotes,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                if (dailyNoteProvider.dailyNotes.isEmpty) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 时间筛选
                          _buildTimeFilter(),

                          // 快速记录区域
                          _buildQuickNoteArea(),

                          // 空状态提示
                          const SizedBox(height: 40),
                          const Icon(Icons.note_alt_outlined,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            '没有日常点滴记录',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _addDailyNote,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3ECABB),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('添加第一条点滴'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 时间筛选
                        _buildTimeFilter(),

                        // 备忘统计
                        _buildNoteStatistics(),

                        // 快速记录区域
                        _buildQuickNoteArea(),

                        // 显示点滴记录
                        _buildDailyNotesList(),

                        // 加载更多
                        _buildLoadMore(),
                      ],
                    ),
                  ),
                );
              },
            ),
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
        children: [
          _buildFilterChip('全部'),
          const SizedBox(width: 8),
          _buildFilterChip('今天'),
          const SizedBox(width: 8),
          _buildFilterChip('本周'),
          const SizedBox(width: 8),
          _buildFilterChip('本月'),
          const SizedBox(width: 8),
          _buildFilterChip('本季度'),
        ],
      ),
    );
  }

  // 构建点滴统计
  Widget _buildNoteStatistics() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '点滴统计',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('总计', _statistics['total'].toString(),
                  const Color(0xFF3ECABB)),
              _buildStatItem('本日', _statistics['today'].toString(),
                  const Color(0xFF3E8ECA)),
              _buildStatItem('本周', _statistics['week'].toString(),
                  const Color(0xFFB23ECA)),
              _buildStatItem('本月', _statistics['month'].toString(),
                  const Color(0xFF3ECA5E)),
              _buildStatItem(
                  '本季', _statistics['quarter'].toString(), Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  // 构建统计项
  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // 构建筛选选项
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        _loadFilteredDailyNotes();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3ECABB) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 构建快速记录区域
  Widget _buildQuickNoteArea() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // 用户信息
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackWithOpacity10,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const Text(
                '此刻有什么想法？',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 输入框
          TextField(
            controller: _quickNoteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '记录你的工作点滴...',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),

          // 底部工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 媒体按钮
              Row(
                children: [
                  _buildMediaButton(Icons.camera_alt),
                  const SizedBox(width: 12),
                  _buildMediaButton(Icons.image),
                  const SizedBox(width: 12),
                  _buildMediaButton(Icons.attach_file),
                ],
              ),

              // 发布按钮
              ElevatedButton(
                onPressed: _addQuickNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3ECABB),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('发布'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建媒体按钮
  Widget _buildMediaButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.grey.shade500,
      ),
    );
  }

  // 构建日期分隔线
  Widget _buildDateDivider(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.shade200,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              date,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.shade200,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 构建点滴记录列表
  Widget _buildDailyNotesList() {
    if (_displayedNotes.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '没有点滴记录',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // 按日期分组点滴
    final Map<String, List<DailyNote>> groupedNotes = {};

    for (final note in _displayedNotes) {
      final dateKey = _getDateText(note.createdAt);
      if (!groupedNotes.containsKey(dateKey)) {
        groupedNotes[dateKey] = [];
      }
      groupedNotes[dateKey]!.add(note);
    }

    // 按日期顺序排列
    final sortedDates = groupedNotes.keys.toList()
      ..sort((a, b) {
        if (a == '今天') return -1;
        if (b == '今天') return 1;
        if (a == '昨天') return -1;
        if (b == '昨天') return 1;
        if (a == '前天') return -1;
        if (b == '前天') return 1;
        return b.compareTo(a); // 其他日期按降序排列
      });

    return Column(
      children: sortedDates.map((date) {
        return Column(
          children: [
            // 日期分隔线
            _buildDateDivider(date),
            // 该日期下的点滴列表
            ...groupedNotes[date]!
                .map((note) => _buildDailyNoteItem(note))
                .toList(),
          ],
        );
      }).toList(),
    );
  }

  // 获取日期文本
  String _getDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
    } else if (dateOnly == dayBeforeYesterday) {
      return '前天';
    } else {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  // 构建点滴项
  Widget _buildDailyNoteItem(DailyNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 作者和时间
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(note.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      if (note.location != null &&
                          note.location!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          note.location!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              note.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),

          // 代码片段（如果有）
          if (note.codeSnippet != null && note.codeSnippet!.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '代码片段',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy,
                                size: 16, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // 复制代码
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.content_copy,
                                size: 16, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // 复制代码
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.codeSnippet!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // 图片（如果有）
          if (note.images != null && note.images!.isNotEmpty)
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(File(note.images![0])),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // 底部操作栏 - 修改为编辑和删除功能
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 编辑按钮
                GestureDetector(
                  onTap: () => _editDailyNote(note),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 删除按钮
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(note),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建加载更多
  Widget _buildLoadMore() {
    if (!_hasMoreNotes) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          '没有更多内容了',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GestureDetector(
      onTap: _loadMoreDailyNotes,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoadingMore
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '加载更多',
                    style: TextStyle(
                      color: Color(0xFF3ECABB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF3ECABB),
                    size: 16,
                  ),
                ],
              ),
      ),
    );
  }

  // 编辑日常点滴
  void _editDailyNote(DailyNote note) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addDailyNote,
      arguments: note,
    );

    if (result == true && mounted) {
      _loadFilteredDailyNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('点滴已更新'),
          backgroundColor: Color(0xFF3ECABB),
        ),
      );
    }
  }

  // 显示删除确认对话框
  void _showDeleteConfirmation(DailyNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条点滴吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDailyNote(note.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 删除日常点滴
  Future<void> _deleteDailyNote(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final success =
          await Provider.of<DailyNoteProvider>(context, listen: false)
              .deleteDailyNote(id);

      if (success && mounted) {
        _loadFilteredDailyNotes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('点滴已删除'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('删除失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
