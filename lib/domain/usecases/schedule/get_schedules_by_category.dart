import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class GetSchedulesByCategory {
  final ScheduleRepository repository;

  GetSchedulesByCategory(this.repository);

  Future<Result<List<ScheduleModel>>> call(String category) async {
    try {
      return await repository.getSchedulesByCategory(category);
    } catch (e) {
      return Result.failure("获取分类日程失败: $e");
    }
  }
} 