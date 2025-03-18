import 'package:intellimate/domain/entities/goal.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/goal_model.dart';

abstract class GoalRepository {
  // 获取所有目标
  Future<Result<List<GoalModel>>> getAllGoals();
  
  // 按类别获取目标
  Future<Result<List<GoalModel>>> getGoalsByCategory(String category);
  
  // 按状态获取目标
  Future<Result<List<GoalModel>>> getGoalsByStatus(String status);
  
  // 按ID获取目标
  Future<Result<GoalModel>> getGoalById(String id);
  
  // 创建目标
  Future<Result<GoalModel>> createGoal({
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    required double progress,
    required String status,
    String? category,
    List<String>? milestones,
  });
  
  // 更新目标
  Future<Result<GoalModel>> updateGoal(Goal goal);
  
  // 更新目标进度
  Future<Result<GoalModel>> updateGoalProgress(String id, double progress);
  
  // 更新目标状态
  Future<Result<GoalModel>> updateGoalStatus(String id, String status);
  
  // 删除目标
  Future<Result<bool>> deleteGoal(String id);
  
  // 搜索目标
  Future<Result<List<GoalModel>>> searchGoals(String query);
}