import 'package:intellimate/domain/entities/schedule.dart';

abstract class ScheduleRepository {
  // 获取单个日程
  Future<Schedule?> getScheduleById(String id);
  
  // 创建日程
  Future<Schedule> createSchedule({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    required bool isAllDay,
    String? category,
    required bool isRepeated,
    String? repeatType,
    List<String>? participants,
    String? reminder,
  });
  
  // 更新日程
  Future<bool> updateSchedule(Schedule schedule);
  
  // 删除日程
  Future<bool> deleteSchedule(String id);
  
  // 获取所有日程
  Future<List<Schedule>> getAllSchedules({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  });
  
  // 获取指定日期范围内的日程
  Future<List<Schedule>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeAllDay = true,
    String? category,
    bool? isRepeated,
  });
  
  // 获取指定日期的日程
  Future<List<Schedule>> getSchedulesByDate(
    DateTime date, {
    bool includeAllDay = true,
    String? category,
  });
  
  // 搜索日程
  Future<List<Schedule>> searchSchedules(String query);
  
  // 根据分类获取日程
  Future<List<Schedule>> getSchedulesByCategory(String category);
  
  // 获取今日日程
  Future<List<Schedule>> getTodaySchedules({
    bool includeAllDay = true,
    String? category,
  });
  
  // 获取未来日程
  Future<List<Schedule>> getUpcomingSchedules({
    int limit = 10,
    String? category,
  });
} 