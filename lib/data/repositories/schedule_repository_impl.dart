import 'package:intellimate/data/datasources/schedule_datasource.dart';
import 'package:intellimate/data/models/schedule_model.dart';
import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleDataSource _dataSource;
  
  ScheduleRepositoryImpl(this._dataSource);
  
  @override
  Future<Schedule?> getScheduleById(String id) async {
    return await _dataSource.getScheduleById(id);
  }
  
  @override
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
  }) async {
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
      createdAt: DateTime.now(), // 会在数据源中更新
      updatedAt: DateTime.now(), // 会在数据源中更新
    );
    
    return await _dataSource.createSchedule(schedule);
  }
  
  @override
  Future<bool> updateSchedule(Schedule schedule) async {
    final scheduleModel = ScheduleModel.fromEntity(schedule);
    final result = await _dataSource.updateSchedule(scheduleModel);
    return result > 0;
  }
  
  @override
  Future<bool> deleteSchedule(String id) async {
    final result = await _dataSource.deleteSchedule(id);
    return result > 0;
  }
  
  @override
  Future<List<Schedule>> getAllSchedules({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await _dataSource.getAllSchedules(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
  
  @override
  Future<List<Schedule>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeAllDay = true,
    String? category,
    bool? isRepeated,
  }) async {
    return await _dataSource.getSchedulesByDateRange(
      startDate,
      endDate,
      includeAllDay: includeAllDay,
      category: category,
      isRepeated: isRepeated,
    );
  }
  
  @override
  Future<List<Schedule>> getSchedulesByDate(
    DateTime date, {
    bool includeAllDay = true,
    String? category,
  }) async {
    return await _dataSource.getSchedulesByDate(
      date,
      includeAllDay: includeAllDay,
      category: category,
    );
  }
  
  @override
  Future<List<Schedule>> searchSchedules(String query) async {
    return await _dataSource.searchSchedules(query);
  }
  
  @override
  Future<List<Schedule>> getSchedulesByCategory(String category) async {
    return await _dataSource.getSchedulesByCategory(category);
  }
  
  @override
  Future<List<Schedule>> getTodaySchedules({
    bool includeAllDay = true,
    String? category,
  }) async {
    return await _dataSource.getTodaySchedules(
      includeAllDay: includeAllDay,
      category: category,
    );
  }
  
  @override
  Future<List<Schedule>> getUpcomingSchedules({
    int limit = 10,
    String? category,
  }) async {
    return await _dataSource.getUpcomingSchedules(
      limit: limit,
      category: category,
    );
  }
} 