import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intellimate/presentation/providers/task_provider.dart';
import 'package:intellimate/presentation/providers/schedule_provider.dart';
import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intl/intl.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  // 任务统计数据
  int _totalTasks = 0;
  int _completedTasks = 0;
  
  // 即将到来的日程
  List<Schedule> _upcomingEvents = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // 加载数据
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _loadTaskStats();
      await _loadUpcomingEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
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
  
  // 加载任务统计
  Future<void> _loadTaskStats() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    // 获取今日任务
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    final todayTasks = await taskProvider.getTasksByCondition(
      fromDate: startOfDay,
      toDate: endOfDay,
    );
    
    // 获取今日已完成任务
    final completedTodayTasks = todayTasks.where((task) => task.isCompleted).toList();
    
    if (mounted) {
      setState(() {
        _totalTasks = todayTasks.length;
        _completedTasks = completedTodayTasks.length;
      });
    }
  }
  
  // 加载即将到来的日程
  Future<void> _loadUpcomingEvents() async {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    
    // 获取即将到来的日程（限制最多5个）
    final upcomingEvents = await scheduleProvider.getUpcomingSchedules(limit: 5);
    
    if (mounted) {
      setState(() {
        _upcomingEvents = upcomingEvents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          
          // 顶部栏
          _buildHeader(),
          
          // 内容区域 - 用Expanded包裹确保滚动区域能够填满剩余空间
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 任务统计
                    _buildTaskStats(),
                    
                    const SizedBox(height: 24),
                    
                    // 即将到来的日程
                    _buildUpcomingEvents(),
                    
                    const SizedBox(height: 32),
                    
                    // 快捷操作
                    _buildQuickActions(),
                    
                    const SizedBox(height: 32),
                    
                    // 功能模块
                    _buildModules(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建顶部栏
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      color: const Color(0xFF3ECABB), // primary-400
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '我的助理',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {
              // 跳转到个人信息页面
              Navigator.pushNamed(context, AppRoutes.profileEdit);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=80&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 加载失败时显示备用图标
                    return const Icon(
                      Icons.person,
                      color: Color(0xFF3ECABB),
                      size: 24,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建任务统计
  Widget _buildTaskStats() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日任务',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280), // text-gray-500
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_totalTasks',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937), // text-gray-800
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '已完成',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280), // text-gray-500
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_completedTasks',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937), // text-gray-800
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建即将到来的日程
  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '即将到来',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // text-gray-800
              ),
            ),
            TextButton(
              onPressed: () {
                // 跳转到日程页面
                Navigator.pushNamed(context, AppRoutes.schedule);
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
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (_upcomingEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '暂无即将到来的日程',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          )
        else
          ..._upcomingEvents.map((event) => _buildEventCard(event)),
      ],
    );
  }

  // 构建日程卡片
  Widget _buildEventCard(Schedule event) {
    // 格式化时间
    final startTime = DateFormat('HH:mm').format(event.startTime);
    final endTime = DateFormat('HH:mm').format(event.endTime);
    final timeDisplay = '$startTime - $endTime';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(
          left: BorderSide(
            color: Color(0xFF3ECABB), // primary-400
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeDisplay,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3ECABB), // primary-400
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937), // text-gray-800
            ),
          ),
          if (event.location != null && event.location!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: 12,
                  color: Color(0xFF6B7280), // text-gray-500
                ),
                const SizedBox(width: 4),
                Text(
                  event.location!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280), // text-gray-500
                  ),
                ),
              ],
            ),
          ],
          // 添加编辑和删除按钮
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  // 编辑日程事件
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.addSchedule,  // 使用已有的添加日程页面
                    arguments: event,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5), // green-50
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF10B981), // green-500
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // 显示确认对话框
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('确认删除'),
                      content: Text('确定要删除日程"${event.title}"吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // 关闭对话框
                            
                            // 获取ScheduleProvider并删除日程
                            final scheduleProvider = Provider.of<ScheduleProvider>(
                              context, 
                              listen: false
                            );
                            
                            try {
                              await scheduleProvider.deleteSchedule(event.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('日程已删除')),
                                );
                                // 重新加载数据
                                _loadUpcomingEvents();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('删除失败: $e')),
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2), // red-50
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 16,
                    color: Color(0xFFEF4444), // red-500
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建快捷操作
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937), // text-gray-800
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: [
            _buildQuickActionItem(
              icon: FontAwesomeIcons.pen,
              label: '点滴记录',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addDailyNote);
              },
            ),
            _buildQuickActionItem(
              icon: FontAwesomeIcons.calendarPlus,
              label: '添加日程',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addSchedule);
              },
            ),
            _buildQuickActionItem(
              icon: FontAwesomeIcons.plus,
              label: '新建任务',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addTask);
              },
            ),
            _buildQuickActionItem(
              icon: FontAwesomeIcons.solidNoteSticky,
              label: '添加备忘',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addMemo);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 构建快捷操作项
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: const Color(0xFF3ECABB), // primary-400
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280), // text-gray-500
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 构建功能模块
  Widget _buildModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '功能模块',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937), // text-gray-800
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: [
            _buildModuleItem(
              title: '笔记管理',
              icon: FontAwesomeIcons.book,
              startColor: const Color(0xFFFBBF24), // from-yellow-400
              endColor: const Color(0xFFF59E0B), // to-yellow-500
              onTap: () {
                // 直接导航到笔记页面
                Navigator.pushNamed(context, AppRoutes.note);
              },
            ),
            _buildModuleItem(
              title: '财务管理',
              icon: FontAwesomeIcons.wallet,
              startColor: const Color(0xFFF87171), // from-red-400
              endColor: const Color(0xFFEF4444), // to-red-500
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.finance);
              },
            ),
            _buildModuleItem(
              title: '图片管理',
              icon: FontAwesomeIcons.images,
              startColor: const Color(0xFFF472B6), // from-pink-400
              endColor: const Color(0xFFEC4899), // to-pink-500
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.photoGallery);
              },
            ),
            _buildModuleItem(
              title: '目标管理',
              icon: FontAwesomeIcons.bullseye,
              startColor: const Color(0xFFA5B4FC), // from-indigo-400
              endColor: const Color(0xFF818CF8), // to-indigo-500
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.goal);
              },
            ),
            _buildModuleItem(
              title: '旅游管理',
              icon: FontAwesomeIcons.plane,
              startColor: const Color(0xFF7DD3FC), // from-blue-300
              endColor: const Color(0xFF38BDF8), // to-blue-400
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.travel);
              },
            ),
            _buildModuleItem(
              title: '系统设置',
              icon: FontAwesomeIcons.cog,
              startColor: const Color(0xFF9CA3AF), // from-gray-400
              endColor: const Color(0xFF6B7280), // to-gray-500
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 构建模块项
  Widget _buildModuleItem({
    required String title,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: startColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
