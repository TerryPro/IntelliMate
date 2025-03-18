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
  final CreateSchedule _createScheduleUseCase;
  final DeleteSchedule _deleteScheduleUseCase;
  final GetAllSchedules _getAllSchedulesUseCase;
  final GetScheduleById _getScheduleByIdUseCase;
  final GetSchedulesByCategory _getSchedulesByCategoryUseCase;
  final GetSchedulesByDate _getSchedulesByDateUseCase;
  final GetSchedulesByDateRange _getSchedulesByDateRangeUseCase;
  final GetTodaySchedules _getTodaySchedulesUseCase;
  final GetUpcomingSchedules _getUpcomingSchedulesUseCase;
  final SearchSchedules _searchSchedulesUseCase;
  final UpdateSchedule _updateScheduleUseCase;

  // 状态变量
  List<Schedule> _schedules = [];
  Schedule? _selectedSchedule;
  bool _isLoading = false;
  String? _error;

  // Getter
  List<Schedule> get schedules => _schedules;
  Schedule? get selectedSchedule => _selectedSchedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ScheduleProvider({
    required CreateSchedule createScheduleUseCase,
    required DeleteSchedule deleteScheduleUseCase,
    required GetAllSchedules getAllSchedulesUseCase,
    required GetScheduleById getScheduleByIdUseCase,
    required GetSchedulesByCategory getSchedulesByCategoryUseCase,
    required GetSchedulesByDate getSchedulesByDateUseCase,
    required GetSchedulesByDateRange getSchedulesByDateRangeUseCase,
    required GetTodaySchedules getTodaySchedulesUseCase,
    required GetUpcomingSchedules getUpcomingSchedulesUseCase,
    required SearchSchedules searchSchedulesUseCase,
    required UpdateSchedule updateScheduleUseCase,
  })  : _createScheduleUseCase = createScheduleUseCase,
        _deleteScheduleUseCase = deleteScheduleUseCase,
        _getAllSchedulesUseCase = getAllSchedulesUseCase,
        _getScheduleByIdUseCase = getScheduleByIdUseCase,
        _getSchedulesByCategoryUseCase = getSchedulesByCategoryUseCase,
        _getSchedulesByDateUseCase = getSchedulesByDateUseCase,
        _getSchedulesByDateRangeUseCase = getSchedulesByDateRangeUseCase,
        _getTodaySchedulesUseCase = getTodaySchedulesUseCase,
        _getUpcomingSchedulesUseCase = getUpcomingSchedulesUseCase,
        _searchSchedulesUseCase = searchSchedulesUseCase,
        _updateScheduleUseCase = updateScheduleUseCase;

  // 获取所有日程
  Future<List<Schedule>> getAllSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getAllSchedulesUseCase.call();
      result.fold(
        onSuccess: (data) => _schedules = data,
        onFailure: (error) => _error = error
      );
      
      _isLoading = false;
      notifyListeners();
      return _schedules;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 根据ID获取日程
  Future<Schedule?> getScheduleById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getScheduleByIdUseCase.call(id);
      
      Schedule? schedule;
      result.fold(
        onSuccess: (data) {
          _selectedSchedule = data;
          schedule = data;
        },
        onFailure: (error) {
          _error = error;
          schedule = null;
        }
      );
      
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
    required DateTime startTime,
    required DateTime endTime,
    required bool isAllDay,
    required bool isRepeated,
    String? description,
    String? location,
    String? category,
    String? repeatType,
    List<String>? participants,
    String? reminder,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _createScheduleUseCase.call(
        title: title,
        startTime: startTime,
        endTime: endTime,
        isAllDay: isAllDay,
        isRepeated: isRepeated,
        description: description,
        location: location,
        category: category,
        repeatType: repeatType,
        participants: participants,
        reminder: reminder,
      );
      
      Schedule? createdSchedule;
      result.fold(
        onSuccess: (data) {
          createdSchedule = data;
          _schedules.add(data);
        },
        onFailure: (error) {
          _error = error;
          createdSchedule = null;
        }
      );
      
      _isLoading = false;
      notifyListeners();
      return createdSchedule;
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
      final result = await _updateScheduleUseCase.call(schedule);
      
      bool success = false;
      result.fold(
        onSuccess: (data) {
          success = true;
          final index = _schedules.indexWhere((s) => s.id == schedule.id);
          if (index != -1) {
            _schedules[index] = schedule;
          }
          if (_selectedSchedule?.id == schedule.id) {
            _selectedSchedule = schedule;
          }
        },
        onFailure: (error) {
          _error = error;
          success = false;
        }
      );
      
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
      final result = await _deleteScheduleUseCase.call(id);
      
      bool success = false;
      result.fold(
        onSuccess: (data) {
          success = data;
          if (success) {
            _schedules.removeWhere((schedule) => schedule.id == id);
            if (_selectedSchedule?.id == id) {
              _selectedSchedule = null;
            }
          }
        },
        onFailure: (error) {
          _error = error;
          success = false;
        }
      );
      
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

  // 按日期范围获取日程
  Future<List<Schedule>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeAllDay = true,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getSchedulesByDateRangeUseCase.call(
        startDate,
        endDate,
        includeAllDay: includeAllDay,
        category: category,
      );
      
      List<Schedule> schedules = [];
      result.fold(
        onSuccess: (data) {
          schedules = data;
          _schedules = data;
        },
        onFailure: (error) {
          _error = error;
          schedules = [];
        }
      );
      
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
      final result = await _getSchedulesByDateUseCase.call(
        date,
        includeAllDay: includeAllDay,
        category: category,
      );
      
      List<Schedule> schedules = [];
      result.fold(
        onSuccess: (data) {
          schedules = data;
          _schedules = data;
        },
        onFailure: (error) {
          _error = error;
          schedules = [];
        }
      );
      
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
      final result = await _searchSchedulesUseCase.call(query);
      
      List<Schedule> schedules = [];
      result.fold(
        onSuccess: (data) {
          schedules = data;
          _schedules = data;
        },
        onFailure: (error) {
          _error = error;
          schedules = [];
        }
      );
      
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
      final result = await _getSchedulesByCategoryUseCase.call(category);
      
      List<Schedule> schedules = [];
      result.fold(
        onSuccess: (data) {
          schedules = data;
          _schedules = data;
        },
        onFailure: (error) {
          _error = error;
          schedules = [];
        }
      );
      
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

  // 获取今天的日程
  Future<List<Schedule>> getTodaySchedules({
    bool includeAllDay = true,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getTodaySchedulesUseCase.call(
        includeAllDay: includeAllDay,
        category: category,
      );
      
      List<Schedule> schedules = [];
      result.fold(
        onSuccess: (data) {
          schedules = data;
          _schedules = data;
        },
        onFailure: (error) {
          _error = error;
          schedules = [];
        }
      );
      
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
      final result = await _getUpcomingSchedulesUseCase.call(
        limit: limit,
        category: category,
      );
      
      List<Schedule> schedules = [];
      result.fold(
        onSuccess: (data) {
          schedules = data;
          _schedules = data;
        },
        onFailure: (error) {
          _error = error;
          schedules = [];
        }
      );
      
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

  // 获取明天的日程
  Future<List<Schedule>> getTomorrowSchedules() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return getSchedulesByDate(tomorrow);
  }

  // 获取本周的日程
  Future<Map<DateTime, List<Schedule>>> getThisWeekSchedules() async {
    final now = DateTime.now();
    final firstDayOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    
    // 获取本周内所有日程
    final weekSchedules = await getSchedulesByDateRange(
      firstDayOfWeek,
      lastDayOfWeek,
    );

    // 按日期分组
    final Map<DateTime, List<Schedule>> schedulesMap = {};
    for (var i = 0; i < 7; i++) {
      final day = firstDayOfWeek.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      
      final daySchedules = weekSchedules.where((schedule) {
        final scheduleDate = DateTime(
          schedule.startTime.year,
          schedule.startTime.month,
          schedule.startTime.day,
        );
        return scheduleDate.isAtSameMomentAs(dayKey);
      }).toList();
      
      schedulesMap[dayKey] = daySchedules;
    }
    
    return schedulesMap;
  }

  // 获取本月的日程
  Future<Map<DateTime, List<Schedule>>> getThisMonthSchedules() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // 获取本月内所有日程
    final monthSchedules = await getSchedulesByDateRange(
      firstDayOfMonth,
      lastDayOfMonth,
    );

    // 按日期分组
    final Map<DateTime, List<Schedule>> schedulesMap = {};
    for (var i = 0; i < lastDayOfMonth.day; i++) {
      final day = firstDayOfMonth.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      
      final daySchedules = monthSchedules.where((schedule) {
        final scheduleDate = DateTime(
          schedule.startTime.year,
          schedule.startTime.month,
          schedule.startTime.day,
        );
        return scheduleDate.isAtSameMomentAs(dayKey);
      }).toList();
      
      schedulesMap[dayKey] = daySchedules;
    }
    
    return schedulesMap;
  }

  // 获取未来7天的日程
  Future<List<Schedule>> getNext7DaysSchedules() async {
    final now = DateTime.now();
    final future7Days = now.add(const Duration(days: 7));
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 在本地过滤未来7天的日程
      await getAllSchedules();
      final next7DaysSchedules = _schedules.where((schedule) {
        return schedule.startTime.isAfter(now) && 
               schedule.startTime.isBefore(future7Days);
      }).toList();
      return next7DaysSchedules;
    } catch (e) {
      _error = '获取未来7天日程失败: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取未完成的日程
  Future<List<Schedule>> getIncompleteSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 在本地过滤未完成的日程（假设未完成的日程是结束时间在当前时间之后的日程）
      await getAllSchedules();
      final now = DateTime.now();
      final incompleteSchedules = _schedules.where((schedule) {
        return schedule.endTime.isAfter(now);
      }).toList();
      return incompleteSchedules;
    } catch (e) {
      _error = '获取未完成日程失败: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取重要的日程
  Future<List<Schedule>> getImportantSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 在本地过滤重要的日程（这里可以根据实际需求定义重要日程的标准）
      // 例如：假设category为"important"的是重要日程
      await getAllSchedules();
      final importantSchedules = _schedules.where((schedule) {
        return schedule.category == 'important';
      }).toList();
      return importantSchedules;
    } catch (e) {
      _error = '获取重要日程失败: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 设置错误信息
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // 清除错误信息
  void _clearError() {
    _error = null;
  }
} 