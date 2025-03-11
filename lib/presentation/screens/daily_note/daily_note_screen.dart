import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/presentation/providers/daily_note_provider.dart';
import 'package:intl/intl.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class DailyNoteScreen extends StatefulWidget {
  const DailyNoteScreen({super.key});

  @override
  State<DailyNoteScreen> createState() => _DailyNoteScreenState();
}

class _DailyNoteScreenState extends State<DailyNoteScreen> {
  String _selectedFilter = '全部';
  String _selectedCalendarView = '周';
  final TextEditingController _quickNoteController = TextEditingController();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDailyNotes();
  }
  
  // 加载日常点滴数据
  Future<void> _loadDailyNotes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Provider.of<DailyNoteProvider>(context, listen: false).getAllDailyNotes();
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
      _loadDailyNotes();
      
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
      await Provider.of<DailyNoteProvider>(context, listen: false).createDailyNote(
        content: _quickNoteController.text.trim(),
        isPrivate: false,
      );
      
      _quickNoteController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('点滴已发布'),
          backgroundColor: Color(0xFF3ECABB),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发布失败: $e')),
      );
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
          // 自定义顶部导航栏
          _buildCustomAppBar(),
          
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
                          onPressed: _loadDailyNotes,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (dailyNoteProvider.dailyNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
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
                  );
                }
                
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 时间筛选
                        _buildTimeFilter(),
                        
                        // 日历视图切换
                        _buildCalendarView(),
                        
                        // 搜索框
                        _buildSearchBar(),
                        
                        // 快速记录区域
                        _buildQuickNoteArea(),
                        
                        // 日期分隔线 - 今天
                        _buildDateDivider('今天'),
                        
                        // 今天的点滴内容列表
                        _buildTodayNotes(dailyNoteProvider),
                        
                        // 日期分隔线 - 昨天
                        _buildDateDivider('昨天'),
                        
                        // 昨天的点滴内容列表
                        _buildYesterdayNotes(dailyNoteProvider),
                        
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
      // 新增记录浮动按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _addDailyNote,
        backgroundColor: const Color(0xFF3ECABB),
        child: const Icon(Icons.edit, color: Colors.white),
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
                '日常点滴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
              onPressed: _addDailyNote,
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
        ],
      ),
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
  
  // 构建日历视图切换
  Widget _buildCalendarView() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
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
          // 视图切换选项卡
          Row(
            children: [
              _buildCalendarViewTab('日'),
              _buildCalendarViewTab('周'),
              _buildCalendarViewTab('月'),
            ],
          ),
          // 日历标题
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.chevron_left, color: Colors.grey.shade400),
                const Text(
                  '2023年7月第3周',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建日历视图选项卡
  Widget _buildCalendarViewTab(String label) {
    final isSelected = _selectedCalendarView == label;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCalendarView = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3ECABB) : Colors.transparent,
            border: const Border(
              bottom: BorderSide(
                color: Colors.black12,
                width: 1,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  // 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索笔记...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
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
                    image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  
  // 构建今天的点滴内容列表
  Widget _buildTodayNotes(DailyNoteProvider provider) {
    // 过滤今天的点滴
    final now = DateTime.now();
    final todayNotes = provider.dailyNotes.where((note) {
      final noteDate = note.createdAt;
      return noteDate.year == now.year && 
             noteDate.month == now.month && 
             noteDate.day == now.day;
    }).toList();
    
    if (todayNotes.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '今天还没有点滴记录',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return Column(
      children: todayNotes.map((note) => _buildDailyNoteItem(note)).toList(),
    );
  }
  
  // 构建昨天的点滴内容列表
  Widget _buildYesterdayNotes(DailyNoteProvider provider) {
    // 过滤昨天的点滴
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayNotes = provider.dailyNotes.where((note) {
      final noteDate = note.createdAt;
      return noteDate.year == yesterday.year && 
             noteDate.month == yesterday.month && 
             noteDate.day == yesterday.day;
    }).toList();
    
    if (yesterdayNotes.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '昨天没有点滴记录',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return Column(
      children: yesterdayNotes.map((note) => _buildDailyNoteItem(note)).toList(),
    );
  }
  
  // 构建点滴项
  Widget _buildDailyNoteItem(DailyNote note) {
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                // 头像
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3ECABB),
                  ),
                  child: Center(
                    child: Text(
                      note.author?.substring(0, 1) ?? '用',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 作者和时间
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.author ?? '用户',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        timeFormat.format(note.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // 更多操作按钮
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {
                    // 显示更多操作菜单
                  },
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
                            icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // 复制代码
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.content_copy, size: 16, color: Colors.grey),
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
                  image: AssetImage(note.images![0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // 底部操作栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // 点赞按钮
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.thumb_up_outlined, size: 18, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            // 点赞功能
                          },
                        ),
                        const SizedBox(width: 4),
                        Text(
                          note.likes.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // 评论按钮
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            // 评论功能
                          },
                        ),
                        const SizedBox(width: 4),
                        Text(
                          note.comments.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // 分享按钮
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // 分享功能
                  },
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
    return GestureDetector(
      onTap: () {
        // 加载更多内容
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
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
  
  // 获取日期文本
  String _getDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
    } else {
      return DateFormat('MM-dd').format(date);
    }
  }
} 