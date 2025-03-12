import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/presentation/providers/schedule_provider.dart';
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
          // 自定义顶部导航栏
          _buildCustomAppBar(),
          
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
                '日程管理',
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
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addSchedule);
              },
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
      onTap: () {
        // 导航到编辑日程界面
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间
              Text(
                '${startTimeFormat.format(schedule.startTime)} - ${endTimeFormat.format(schedule.endTime)}',
                style: const TextStyle(
                  color: Color(0xFF3ECABB),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              
              // 标题
              Text(
                schedule.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              
              // 位置
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    schedule.location ?? '无地点',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 