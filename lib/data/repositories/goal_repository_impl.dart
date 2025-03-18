import 'package:intellimate/data/datasources/goal_datasource.dart';
import 'package:intellimate/data/models/goal_model.dart';
import 'package:intellimate/domain/entities/goal.dart';
import 'package:intellimate/domain/repositories/goal_repository.dart';
import 'package:intellimate/domain/core/result.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalDataSource _dataSource;

  GoalRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<GoalModel>>> getAllGoals() async {
    try {
      final goals = await _dataSource.getAllGoals();
      return Result.success(goals);
    } catch (e) {
      return Result.failure("获取所有目标失败: $e");
    }
  }

  @override
  Future<Result<List<GoalModel>>> getGoalsByCategory(String category) async {
    try {
      final goals = await _dataSource.getGoalsByCategory(category);
      return Result.success(goals);
    } catch (e) {
      return Result.failure("获取分类目标失败: $e");
    }
  }

  @override
  Future<Result<List<GoalModel>>> getGoalsByStatus(String status) async {
    try {
      final goals = await _dataSource.getGoalsByStatus(status);
      return Result.success(goals);
    } catch (e) {
      return Result.failure("获取状态目标失败: $e");
    }
  }

  @override
  Future<Result<GoalModel>> getGoalById(String id) async {
    try {
      final goal = await _dataSource.getGoalById(id);
      if (goal == null) {
        return Result.failure("找不到ID为$id的目标");
      }
      return Result.success(goal);
    } catch (e) {
      return Result.failure("获取目标详情失败: $e");
    }
  }

  @override
  Future<Result<GoalModel>> createGoal({
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    required double progress,
    required String status,
    String? category,
    List<String>? milestones,
  }) async {
    try {
      final now = DateTime.now();
      final goalModel = GoalModel(
        id: '', // 会在数据源中生成
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        progress: progress,
        status: status,
        category: category,
        milestones: milestones,
        createdAt: now,
        updatedAt: now,
      );
      
      final result = await _dataSource.createGoal(goalModel);
      return Result.success(result);
    } catch (e) {
      return Result.failure("创建目标失败: $e");
    }
  }

  @override
  Future<Result<GoalModel>> updateGoal(Goal goal) async {
    try {
      final goalModel = GoalModel.fromEntity(goal);
      final affected = await _dataSource.updateGoal(goalModel);
      if (affected > 0) {
        // 获取更新后的数据并返回
        final updated = await _dataSource.getGoalById(goal.id);
        if (updated != null) {
          return Result.success(updated);
        }
        return Result.success(goalModel);
      } else {
        return Result.failure("更新目标失败: 没有记录被更新");
      }
    } catch (e) {
      return Result.failure("更新目标失败: $e");
    }
  }

  @override
  Future<Result<GoalModel>> updateGoalProgress(String id, double progress) async {
    try {
      final result = await _dataSource.updateGoalProgress(id, progress);
      if (result > 0) {
        // 获取更新后的目标
        final updated = await _dataSource.getGoalById(id);
        if (updated != null) {
          return Result.success(updated);
        }
        return Result.failure("更新目标进度成功但获取更新后的数据失败");
      } else {
        return Result.failure("更新目标进度失败: 没有记录被更新");
      }
    } catch (e) {
      return Result.failure("更新目标进度失败: $e");
    }
  }

  @override
  Future<Result<GoalModel>> updateGoalStatus(String id, String status) async {
    try {
      final result = await _dataSource.updateGoalStatus(id, status);
      if (result > 0) {
        // 获取更新后的目标
        final updated = await _dataSource.getGoalById(id);
        if (updated != null) {
          return Result.success(updated);
        }
        return Result.failure("更新目标状态成功但获取更新后的数据失败");
      } else {
        return Result.failure("更新目标状态失败: 没有记录被更新");
      }
    } catch (e) {
      return Result.failure("更新目标状态失败: $e");
    }
  }

  @override
  Future<Result<bool>> deleteGoal(String id) async {
    try {
      final result = await _dataSource.deleteGoal(id);
      if (result > 0) {
        return Result.success(true);
      } else {
        return Result.failure("删除目标失败: 没有记录被删除");
      }
    } catch (e) {
      return Result.failure("删除目标失败: $e");
    }
  }

  @override
  Future<Result<List<GoalModel>>> searchGoals(String query) async {
    try {
      final goals = await _dataSource.searchGoals(query);
      return Result.success(goals);
    } catch (e) {
      return Result.failure("搜索目标失败: $e");
    }
  }
}