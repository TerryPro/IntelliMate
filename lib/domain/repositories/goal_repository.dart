 import 'package:intellimate/domain/entities/goal.dart';

abstract class GoalRepository {
  // 获取所有目标
  Future<List<Goal>> getAllGoals();
  
  // 按类别获取目标
  Future<List<Goal>> getGoalsByCategory(String category);
  
  // 按状态获取目标
  Future<List<Goal>> getGoalsByStatus(String status);
  
  // 按ID获取目标
  Future<Goal?> getGoalById(String id);
  
  // 创建目标
  Future<Goal> createGoal(Goal goal);
  
  // 更新目标
  Future<bool> updateGoal(Goal goal);
  
  // 更新目标进度
  Future<bool> updateGoalProgress(String id, double progress);
  
  // 更新目标状态
  Future<bool> updateGoalStatus(String id, String status);
  
  // 删除目标
  Future<bool> deleteGoal(String id);
  
  // 搜索目标
  Future<List<Goal>> searchGoals(String query);
}