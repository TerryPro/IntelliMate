import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class GetScheduleById {
  final ScheduleRepository repository;

  GetScheduleById(this.repository);

  Future<Result<ScheduleModel>> call(String id) async {
    try {
      return await repository.getScheduleById(id);
    } catch (e) {
      return Result.failure("获取日程详情失败: $e");
    }
  }
} 