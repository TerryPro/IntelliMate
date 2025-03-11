import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/usecases/schedule/create_schedule.dart';
import 'package:intellimate/domain/usecases/schedule/delete_schedule.dart';
import 'package:intellimate/domain/usecases/schedule/get_all_schedules.dart';
import 'package:intellimate/domain/usecases/schedule/get_schedule_by_id.dart';
import 'package:intellimate/domain/usecases/schedule/get_schedules_by_category.dart';
import 'package:intellimate/domain/usecases/schedule/get_schedules_by_date.dart';
import 'package:intellimate/domain/usecases/schedule/get_schedules_by_date_range.dart';
import 'package:intellimate/domain/usecases/schedule/get_today_schedules.dart';
import 'package:intellimate/domain/usecases/schedule/get_upcoming_schedules.dart';
import 'package:intellimate/domain/usecases/schedule/search_schedules.dart';
import 'package:intellimate/domain/usecases/schedule/update_schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  final GetScheduleById _getScheduleByIdUseCase;
  final CreateSchedule _createScheduleUseCase;
  final UpdateSchedule _updateScheduleUseCase;
  final DeleteSchedule _deleteScheduleUseCase;
  final GetAllSchedules _getAllSchedulesUseCase;
  final GetSchedulesByDateRange _getSchedulesByDateRangeUseCase;
  final GetSchedulesByDate _getSchedulesByDateUseCase;
  final SearchSchedules _searchSchedulesUseCase;
  final GetSchedulesByCategory _getSchedulesByCategoryUseCase;
  final GetTodaySchedules _getTodaySchedulesUseCase;
  final GetUpcomingSchedules _getUpcomingSchedulesUseCase;

  ScheduleProvider({
    required GetScheduleById getScheduleByIdUseCase,
    required CreateSchedule createScheduleUseCase,
    required UpdateSchedule updateScheduleUseCase,
    required DeleteSchedule deleteScheduleUseCase,
    required GetAllSchedules getAllSchedulesUseCase,
    required GetSchedulesByDateRange getSchedulesByDateRangeUseCase,
    required GetSchedulesByDate getSchedulesByDateUseCase,
    required SearchSchedules searchSchedulesUseCase,
    required GetSchedulesByCategory getSchedulesByCategoryUseCase,
    required GetTodaySchedules getTodaySchedulesUseCase,
    required GetUpcomingSchedules getUpcomingSchedulesUseCase,
  }) : _getScheduleByIdUseCase = getScheduleByIdUseCase,
       _createScheduleUseCase = createScheduleUseCase,
       _updateScheduleUseCase = updateScheduleUseCase,
       _deleteScheduleUseCase = deleteScheduleUseCase,
       _getAllSchedulesUseCase = getAllSchedulesUseCase,
       _getSchedulesByDateRangeUseCase = getSchedulesByDateRangeUseCase,
       _getSchedulesByDateUseCase = getSchedulesByDateUseCase,
       _searchSchedulesUseCase = searchSchedulesUseCase,
       _getSchedulesByCategoryUseCase = getSchedulesByCategoryUseCase,
       _getTodaySchedulesUseCase = getTodaySchedulesUseCase,
       _getUpcomingSchedulesUseCase = getUpcomingSchedulesUseCase;

  // 状态变量
  bool _isLoading = false;
  String? _error;
  List<Schedule> _schedules = [];
  Schedule? _selectedSchedule;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Schedule> get schedules => _schedules;
  Schedule? get selectedSchedule => _selectedSchedule;

  // 根据ID获取日程
  Future<Schedule?> getScheduleById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedule = await _getScheduleByIdUseCase(id);
      _selectedSchedule = schedule;
      _isLoading = false;
      notifyListeners();
      return schedule;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 创建日程
  Future<Schedule?> createSchedule({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedule = await _createScheduleUseCase(
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
      );
      
      // 更新状态
      _schedules = [..._schedules, schedule];
      _isLoading = false;
      notifyListeners();
      return schedule;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 更新日程
  Future<bool> updateSchedule(Schedule schedule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _updateScheduleUseCase(schedule);
      
      if (success) {
        // 更新本地列表
        final index = _schedules.indexWhere((s) => s.id == schedule.id);
        if (index != -1) {
          _schedules[index] = schedule;
        }
        
        // 如果是当前选中的日程，也更新它
        if (_selectedSchedule?.id == schedule.id) {
          _selectedSchedule = schedule;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 删除日程
  Future<bool> deleteSchedule(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _deleteScheduleUseCase(id);
      
      if (success) {
        // 从列表中移除
        _schedules.removeWhere((schedule) => schedule.id == id);
        
        // 如果是当前选中的日程，清除选中状态
        if (_selectedSchedule?.id == id) {
          _selectedSchedule = null;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 获取所有日程
  Future<List<Schedule>> getAllSchedules({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedules = await _getAllSchedulesUseCase(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      
      _schedules = schedules;
      _isLoading = false;
      notifyListeners();
      return schedules;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 获取指定日期范围内的日程
  Future<List<Schedule>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeAllDay = true,
    String? category,
    bool? isRepeated,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedules = await _getSchedulesByDateRangeUseCase(
        startDate,
        endDate,
        includeAllDay: includeAllDay,
        category: category,
        isRepeated: isRepeated,
      );
      
      _schedules = schedules;
      _isLoading = false;
      notifyListeners();
      return schedules;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 获取指定日期的日程
  Future<List<Schedule>> getSchedulesByDate(
    DateTime date, {
    bool includeAllDay = true,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedules = await _getSchedulesByDateUseCase(
        date,
        includeAllDay: includeAllDay,
        category: category,
      );
      
      _schedules = schedules;
      _isLoading = false;
      notifyListeners();
      return schedules;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 搜索日程
  Future<List<Schedule>> searchSchedules(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedules = await _searchSchedulesUseCase(query);
      
      _schedules = schedules;
      _isLoading = false;
      notifyListeners();
      return schedules;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 根据分类获取日程
  Future<List<Schedule>> getSchedulesByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedules = await _getSchedulesByCategoryUseCase(category);
      
      _schedules = schedules;
      _isLoading = false;
      notifyListeners();
      return schedules;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 获取今日日程
  Future<List<Schedule>> getTodaySchedules({
    bool includeAllDay = true,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedules = await _getTodaySchedulesUseCase(
        includeAllDay: includeAllDay,
        category: category,
      );
      
      _schedules = schedules;
      _isLoading = false;
      notifyListeners();
      return schedules;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 获取未来日程
  Future<List<Schedule>> getUpcomingSchedules({
    int limit = 10,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedules = await _getUpcomingSchedulesUseCase(
        limit: limit,
        category: category,
      );
      
      _schedules = schedules;
      _isLoading = false;
      notifyListeners();
      return schedules;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 设置选中的日程
  void setSelectedSchedule(Schedule? schedule) {
    _selectedSchedule = schedule;
    notifyListeners();
  }
} 