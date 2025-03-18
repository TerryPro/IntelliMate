import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/domain/entities/goal.dart';
import 'package:intellimate/domain/repositories/goal_repository.dart';

class GoalProvider with ChangeNotifier {
  final GoalRepository _goalRepository;
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  GoalProvider(this._goalRepository) {
    loadGoals();
  }

  // 获取状态
  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载所有目标
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _goalRepository.getAllGoals();
      result.fold(
        onSuccess: (data) => _goals = data,
        onFailure: (error) => _error = error
      );
    } catch (e) {
      _error = '加载目标失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 按类别加载目标
  Future<void> loadGoalsByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _goalRepository.getGoalsByCategory(category);
      result.fold(
        onSuccess: (data) => _goals = data,
        onFailure: (error) => _error = error
      );
    } catch (e) {
      _error = '加载目标失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 按状态加载目标
  Future<void> loadGoalsByStatus(String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _goalRepository.getGoalsByStatus(status);
      result.fold(
        onSuccess: (data) => _goals = data,
        onFailure: (error) => _error = error
      );
    } catch (e) {
      _error = '加载目标失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 创建目标
  Future<Goal?> createGoal(Goal goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _goalRepository.createGoal(
        title: goal.title,
        description: goal.description,
        startDate: goal.startDate,
        endDate: goal.endDate,
        progress: goal.progress,
        status: goal.status,
        category: goal.category,
        milestones: goal.milestones,
      );
      
      Goal? newGoal;
      result.fold(
        onSuccess: (data) {
          newGoal = data;
          _goals.add(data);
        },
        onFailure: (error) {
          _error = error;
          newGoal = null;
        }
      );
      return newGoal;
    } catch (e) {
      _error = '创建目标失败: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新目标
  Future<bool> updateGoal(Goal goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _goalRepository.updateGoal(goal);
      bool success = false;
      
      result.fold(
        onSuccess: (data) {
          success = true;
          final index = _goals.indexWhere((g) => g.id == goal.id);
          if (index != -1) {
            _goals[index] = goal;
          }
        },
        onFailure: (error) {
          _error = error;
          success = false;
        }
      );
      
      return success;
    } catch (e) {
      _error = '更新目标失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新目标进度
  Future<bool> updateGoalProgress(String id, double progress) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _goalRepository.updateGoalProgress(id, progress);
      bool success = false;
      
      result.fold(
        onSuccess: (data) {
          success = true;
          final index = _goals.indexWhere((g) => g.id == id);
          if (index != -1) {
            final goal = _goals[index];
            _goals[index] = Goal(
              id: goal.id,
              title: goal.title,
              description: goal.description,
              startDate: goal.startDate,
              endDate: goal.endDate,
              progress: progress,
              status: goal.status,
              category: goal.category,
              milestones: goal.milestones,
              createdAt: goal.createdAt,
              updatedAt: DateTime.now(),
            );
          }
        },
        onFailure: (error) {
          _error = error;
          success = false;
        }
      );
      
      return success;
    } catch (e) {
      _error = '更新目标进度失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新目标状态
  Future<bool> updateGoalStatus(String id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _goalRepository.updateGoalStatus(id, status);
      bool success = false;
      
      result.fold(
        onSuccess: (data) {
          success = true;
          final index = _goals.indexWhere((g) => g.id == id);
          if (index != -1) {
            final goal = _goals[index];
            _goals[index] = Goal(
              id: goal.id,
              title: goal.title,
              description: goal.description,
              startDate: goal.startDate,
              endDate: goal.endDate,
              progress: goal.progress,
              status: status,
              category: goal.category,
              milestones: goal.milestones,
              createdAt: goal.createdAt,
              updatedAt: DateTime.now(),
            );
          }
        },
        onFailure: (error) {
          _error = error;
          success = false;
        }
      );
      
      return success;
    } catch (e) {
      _error = '更新目标状态失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除目标
  Future<bool> deleteGoal(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _goalRepository.deleteGoal(id);
      bool success = false;
      
      result.fold(
        onSuccess: (data) {
          success = data;
          if (success) {
            _goals.removeWhere((goal) => goal.id == id);
          }
        },
        onFailure: (error) {
          _error = error;
          success = false;
        }
      );
      
      return success;
    } catch (e) {
      _error = '删除目标失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 搜索目标
  Future<void> searchGoals(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (query.isEmpty) {
        await loadGoals();
      } else {
        final result = await _goalRepository.searchGoals(query);
        result.fold(
          onSuccess: (data) => _goals = data,
          onFailure: (error) => _error = error
        );
      }
    } catch (e) {
      _error = '搜索目标失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}