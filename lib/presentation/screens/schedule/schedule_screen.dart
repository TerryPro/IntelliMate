import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/presentation/providers/schedule_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intellimate/app/theme/app_colors.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // 存储日程数据
  Map<DateTime, List<Schedule>> _schedules = {};
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSchedules();
  }
  
  // 加载日程数据
  Future<void> _loadSchedules() async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    
    // 获取当月的开始和结束日期
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // 获取当月的所有日程
      final schedules = await provider.getSchedulesByDateRange(firstDay, lastDay);
      
      // 按日期分组
      final Map<DateTime, List<Schedule>> groupedSchedules = {};
      for (final schedule in schedules) {
        final date = DateTime(
          schedule.startTime.year,
          schedule.startTime.month,
          schedule.startTime.day,
        );
        
        if (groupedSchedules[date] == null) {
          groupedSchedules[date] = [];
        }
        
        groupedSchedules[date]!.add(schedule);
      }
      
      setState(() {
        _schedules = groupedSchedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  // 获取指定日期的日程
  List<Schedule> _getSchedulesForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _schedules[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 使用统一的顶部导航栏
          UnifiedAppBar(
            title: '日程管理',
            actions: [
              AppBarRefreshButton(
                onTap: _loadSchedules,
              ),
              const SizedBox(width: 8),
              AppBarAddButton(
                onTap: () async {
                  final result = await Navigator.pushNamed(context, AppRoutes.addSchedule);
                  if (result == true && mounted) {
                    _loadSchedules();
                  }
                },
              ),
            ],
          ),
          
          // 主体内容
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 日历视图
                  _buildCalendar(),
                  
                  // 当前日期显示
                  _buildCurrentDateHeader(),
                  
                  // 日程列表
                  _buildScheduleList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建日历视图
  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 月份导航
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                      _loadSchedules(); // 加载上个月的日程
                    });
                  },
                  child: const Icon(Icons.chevron_left, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_focusedDay.year}年${_focusedDay.month}月',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                      _loadSchedules(); // 加载下个月的日程
                    });
                  },
                  child: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // 星期标题
          const Row(
            children: [
              Expanded(
                child: Text(
                  '日',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '一',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '二',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '三',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '四',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '五',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '六',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          
          // 日历网格
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerVisible: false, // 隐藏默认的头部
            daysOfWeekVisible: false, // 隐藏默认的星期标题
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: const CalendarStyle(
              // 今天的样式
              todayDecoration: BoxDecoration(
                color: Color(0xFF3ECABB),
                shape: BoxShape.circle,
              ),
              // 选中日期的样式
              selectedDecoration: BoxDecoration(
                color: Color(0xFF3ECABB),
                shape: BoxShape.circle,
              ),
              // 有事件的日期下方的标记
              markerDecoration: BoxDecoration(
                color: Color(0xFF3ECABB),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              markerSize: 4,
              markerMargin: EdgeInsets.only(top: 1),
              // 其他月份的日期样式
              outsideTextStyle: TextStyle(color: Colors.grey),
              // 周末样式
              weekendTextStyle: TextStyle(color: Colors.black),
              // 默认样式
              defaultTextStyle: TextStyle(color: Colors.black),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getSchedulesForDay,
          ),
        ],
      ),
    );
  }
  
  // 构建当前日期头部
  Widget _buildCurrentDateHeader() {
    final now = DateTime.now();
    final isToday = _selectedDay!.year == now.year && 
                    _selectedDay!.month == now.month && 
                    _selectedDay!.day == now.day;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        isToday 
            ? '今天 · ${_selectedDay!.month}月${_selectedDay!.day}日' 
            : '${_selectedDay!.month}月${_selectedDay!.day}日',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
  
  // 构建日程列表
  Widget _buildScheduleList() {
    final schedules = _getSchedulesForDay(_selectedDay ?? _focusedDay);
    
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                '加载日程失败: $_error',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSchedules,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (schedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            '今天没有日程安排',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: schedules.map((schedule) => _buildScheduleItem(schedule)).toList(),
      ),
    );
  }
  
  // 构建日程项
  Widget _buildScheduleItem(Schedule schedule) {
    final startTimeFormat = DateFormat('HH:mm');
    final endTimeFormat = DateFormat('HH:mm');
    
    return GestureDetector(
      onTap: () => _showScheduleDetail(schedule),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          border: const Border(
            left: BorderSide(
              color: Color(0xFF3ECABB),
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          schedule.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        schedule.isAllDay
                            ? '全天'
                            : '${startTimeFormat.format(schedule.startTime)} - ${endTimeFormat.format(schedule.endTime)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  
                  // 描述
                  if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      schedule.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  
                  // 位置
                  if (schedule.location != null && schedule.location!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          schedule.location!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // 底部操作栏 - 编辑和删除功能
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 编辑按钮
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.addSchedule,
                            arguments: schedule.id,
                          ).then((result) {
                            if (result == true) {
                              // 如果编辑成功，重新加载日程
                              _loadSchedules();
                            }
                          });
                        },
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
                        onTap: () => _showDeleteConfirmation(schedule),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 显示日程详情
  void _showScheduleDetail(Schedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScheduleDetailSheet(schedule),
    );
  }
  
  // 构建日程详情底部弹出框
  Widget _buildScheduleDetailSheet(Schedule schedule) {
    final dateFormat = DateFormat('yyyy年MM月dd日');
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拖动条
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                const Text(
                  '日程详情',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // 编辑按钮
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3ECABB)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addSchedule,
                      arguments: schedule.id,
                    ).then((result) {
                      if (result == true) {
                        _loadSchedules();
                      }
                    });
                  },
                ),
                // 删除按钮
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(schedule);
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 详情内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    schedule.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 时间信息
                  _buildDetailItem(
                    icon: Icons.access_time,
                    title: '时间',
                    content: schedule.isAllDay
                        ? '全天 · ${dateFormat.format(schedule.startTime)}'
                        : '${timeFormat.format(schedule.startTime)} - ${timeFormat.format(schedule.endTime)} · ${dateFormat.format(schedule.startTime)}',
                  ),
                  
                  // 地点信息
                  if (schedule.location != null && schedule.location!.isNotEmpty)
                    _buildDetailItem(
                      icon: Icons.location_on,
                      title: '地点',
                      content: schedule.location!,
                    ),
                  
                  // 分类信息
                  if (schedule.category != null)
                    _buildDetailItem(
                      icon: Icons.category,
                      title: '分类',
                      content: schedule.category!,
                    ),
                  
                  // 提醒信息
                  if (schedule.reminder != null && schedule.reminder != '无')
                    _buildDetailItem(
                      icon: Icons.notifications,
                      title: '提醒',
                      content: schedule.reminder!,
                    ),
                  
                  // 描述信息
                  if (schedule.description != null && schedule.description!.isNotEmpty)
                    _buildDetailItem(
                      icon: Icons.description,
                      title: '备注',
                      content: schedule.description!,
                    ),
                  
                  // 创建和更新时间
                  const SizedBox(height: 20),
                  Text(
                    '创建于 ${DateFormat('yyyy-MM-dd HH:mm').format(schedule.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '更新于 ${DateFormat('yyyy-MM-dd HH:mm').format(schedule.updatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建详情项
  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3ECABB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3ECABB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 显示删除确认对话框
  void _showDeleteConfirmation(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个日程吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSchedule(schedule.id);
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
  
  // 删除日程
  Future<void> _deleteSchedule(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final success = await Provider.of<ScheduleProvider>(context, listen: false).deleteSchedule(id);
      
      if (success && mounted) {
        _loadSchedules();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('日程已删除'),
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