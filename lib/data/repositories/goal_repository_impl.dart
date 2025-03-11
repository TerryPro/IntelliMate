 import 'package:intellimate/data/datasources/goal_datasource.dart';
import 'package:intellimate/data/models/goal_model.dart';
import 'package:intellimate/domain/entities/goal.dart';
import 'package:intellimate/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalDataSource _dataSource;

  GoalRepositoryImpl(this._dataSource);

  @override
  Future<List<Goal>> getAllGoals() async {
    return await _dataSource.getAllGoals();
  }

  @override
  Future<List<Goal>> getGoalsByCategory(String category) async {
    return await _dataSource.getGoalsByCategory(category);
  }

  @override
  Future<List<Goal>> getGoalsByStatus(String status) async {
    return await _dataSource.getGoalsByStatus(status);
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    return await _dataSource.getGoalById(id);
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    final goalModel = GoalModel.fromEntity(goal);
    return await _dataSource.createGoal(goalModel);
  }

  @override
  Future<bool> updateGoal(Goal goal) async {
    final goalModel = GoalModel.fromEntity(goal);
    final result = await _dataSource.updateGoal(goalModel);
    return result > 0;
  }

  @override
  Future<bool> updateGoalProgress(String id, double progress) async {
    final result = await _dataSource.updateGoalProgress(id, progress);
    return result > 0;
  }

  @override
  Future<bool> updateGoalStatus(String id, String status) async {
    final result = await _dataSource.updateGoalStatus(id, status);
    return result > 0;
  }

  @override
  Future<bool> deleteGoal(String id) async {
    final result = await _dataSource.deleteGoal(id);
    return result > 0;
  }

  @override
  Future<List<Goal>> searchGoals(String query) async {
    return await _dataSource.searchGoals(query);
  }
}