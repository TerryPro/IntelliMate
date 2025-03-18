import 'package:intellimate/domain/repositories/schedule_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/schedule_model.dart';

class SearchSchedules {
  final ScheduleRepository repository;

  SearchSchedules(this.repository);

  Future<Result<List<ScheduleModel>>> call(String query) async {
    try {
      return await repository.searchSchedules(query);
    } catch (e) {
      return Result.failure("搜索日程失败: $e");
    }
  }
} 