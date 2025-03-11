import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/schedule.dart';
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
  
  // 模拟数据 - 日程列表
  final Map<DateTime, List<Schedule>> _schedules = {
    DateTime.now(): [
      Schedule(
        id: '1',
        title: '团队周会',
        startTime: DateTime.now().copyWith(hour: 9, minute: 0),
        endTime: DateTime.now().copyWith(hour: 10, minute: 30),
        location: '线上会议',
        isAllDay: false,
        isRepeated: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Schedule(
        id: '2',
        title: '产品讨论会议',
        startTime: DateTime.now().copyWith(hour: 14, minute: 0),
        endTime: DateTime.now().copyWith(hour: 15, minute: 0),
        location: '会议室A',
        isAllDay: false,
        isRepeated: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Schedule(
        id: '3',
        title: '健身',
        startTime: DateTime.now().copyWith(hour: 18, minute: 30),
        endTime: DateTime.now().copyWith(hour: 20, minute: 0),
        location: '健身中心',
        isAllDay: false,
        isRepeated: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
    DateTime.now().add(const Duration(days: 1)): [
      Schedule(
        id: '4',
        title: '项目评审',
        startTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 13, minute: 0),
        endTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 14, minute: 30),
        location: '会议室B',
        isAllDay: false,
        isRepeated: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ],
    DateTime.now().add(const Duration(days: 3)): [
      Schedule(
        id: '5',
        title: '客户会面',
        startTime: DateTime.now().add(const Duration(days: 3)).copyWith(hour: 10, minute: 0),
        endTime: DateTime.now().add(const Duration(days: 3)).copyWith(hour: 11, minute: 0),
        location: '咖啡厅',
        isAllDay: false,
        isRepeated: false,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ],
  };
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addSchedule);
        },
        backgroundColor: const Color(0xFF3ECABB),
        shape: const CircleBorder(),
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
    final schedules = _getSchedulesForDay(_selectedDay!);
    
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
    
    return Container(
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
    );
  }
} 