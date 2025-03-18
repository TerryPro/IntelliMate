import 'package:intellimate/data/datasources/schedule_datasource.dart';
import 'package:intellimate/data/models/schedule_model.dart';
import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleDataSource _dataSource;
  
  ScheduleRepositoryImpl(this._dataSource);
  
  @override
  Future<Result<ScheduleModel>> getScheduleById(String id) async {
    try {
      final schedule = await _dataSource.getScheduleById(id);
      if (schedule == null) {
        return Result.failure("找不到ID为$id的日程");
      }
      return Result.success(schedule);
    } catch (e) {
      return Result.failure("获取日程详情失败: $e");
    }
  }
  
  @override
  Future<Result<ScheduleModel>> createSchedule({
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
  }) async {
    try {
      final schedule = ScheduleModel(
        id: '', // 会在数据源中生成
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        location: location,
        isAllDay: isAllDay,
        category: category,
        isRepeated: isRepeated,
        repeatType: repeatType,
        participants: participants,
        reminder: reminder,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final result = await _dataSource.createSchedule(schedule);
      return Result.success(result);
    } catch (e) {
      return Result.failure("创建日程失败: $e");
    }
  }
  
  @override
  Future<Result<ScheduleModel>> updateSchedule(Schedule schedule) async {
    try {
      final scheduleModel = ScheduleModel.fromEntity(schedule);
      final affected = await _dataSource.updateSchedule(scheduleModel);
      if (affected > 0) {
        // 获取更新后的数据
        final updated = await _dataSource.getScheduleById(schedule.id);
        if (updated != null) {
          return Result.success(updated);
        }
        return Result.success(scheduleModel);
      } else {
        return Result.failure("更新日程失败: 没有记录被更新");
      }
    } catch (e) {
      return Result.failure("更新日程失败: $e");
    }
  }
  
  @override
  Future<Result<bool>> deleteSchedule(String id) async {
    try {
      final result = await _dataSource.deleteSchedule(id);
      if (result > 0) {
        return Result.success(true);
      } else {
        return Result.failure("删除日程失败: 没有记录被删除");
      }
    } catch (e) {
      return Result.failure("删除日程失败: $e");
    }
  }
  
  @override
  Future<Result<List<ScheduleModel>>> getAllSchedules({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      final schedules = await _dataSource.getAllSchedules(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      return Result.success(schedules);
    } catch (e) {
      return Result.failure("获取所有日程失败: $e");
    }
  }
  
  @override
  Future<Result<List<ScheduleModel>>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeAllDay = true,
    String? category,
    bool? isRepeated,
  }) async {
    try {
      final schedules = await _dataSource.getSchedulesByDateRange(
        startDate,
        endDate,
        includeAllDay: includeAllDay,
        category: category,
        isRepeated: isRepeated,
      );
      return Result.success(schedules);
    } catch (e) {
      return Result.failure("获取日期范围内的日程失败: $e");
    }
  }
  
  @override
  Future<Result<List<ScheduleModel>>> getSchedulesByDate(
    DateTime date, {
    bool includeAllDay = true,
    String? category,
  }) async {
    try {
      final schedules = await _dataSource.getSchedulesByDate(
        date,
        includeAllDay: includeAllDay,
        category: category,
      );
      return Result.success(schedules);
    } catch (e) {
      return Result.failure("获取指定日期的日程失败: $e");
    }
  }
  
  @override
  Future<Result<List<ScheduleModel>>> searchSchedules(String query) async {
    try {
      final schedules = await _dataSource.searchSchedules(query);
      return Result.success(schedules);
    } catch (e) {
      return Result.failure("搜索日程失败: $e");
    }
  }
  
  @override
  Future<Result<List<ScheduleModel>>> getSchedulesByCategory(String category) async {
    try {
      final schedules = await _dataSource.getSchedulesByCategory(category);
      return Result.success(schedules);
    } catch (e) {
      return Result.failure("获取分类日程失败: $e");
    }
  }
  
  @override
  Future<Result<List<ScheduleModel>>> getTodaySchedules({
    bool includeAllDay = true,
    String? category,
  }) async {
    try {
      final schedules = await _dataSource.getTodaySchedules(
        includeAllDay: includeAllDay,
        category: category,
      );
      return Result.success(schedules);
    } catch (e) {
      return Result.failure("获取今日日程失败: $e");
    }
  }
  
  @override
  Future<Result<List<ScheduleModel>>> getUpcomingSchedules({
    int limit = 10,
    String? category,
  }) async {
    try {
      final schedules = await _dataSource.getUpcomingSchedules(
        limit: limit,
        category: category,
      );
      return Result.success(schedules);
    } catch (e) {
      return Result.failure("获取未来日程失败: $e");
    }
  }
} 