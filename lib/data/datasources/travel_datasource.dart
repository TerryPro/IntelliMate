import 'package:uuid/uuid.dart';
import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/domain/entities/travel.dart';

class TravelDataSource {
  final DatabaseHelper _databaseHelper;
  final _uuid = const Uuid();

  TravelDataSource(this._databaseHelper);

  // 获取所有旅行
  Future<List<Travel>> getTravels() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> travelMaps = await db.query('travels');

    final travels = <Travel>[];
    for (final travelMap in travelMaps) {
      final tasks = await _getTasksForTravel(travelMap['id'] as String);
      travels.add(_mapToTravel(travelMap, tasks));
    }

    return travels;
  }

  // 创建新旅行
  Future<Travel> createTravel(Travel travel) async {
    final db = await _databaseHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now();

    final travelMap = {
      'id': id,
      'title': travel.title,
      'description': travel.description,
      'places': travel.places.join(','),
      'destination': travel.places.isNotEmpty ? travel.places[0] : '未知目的地',
      'start_date': travel.startDate.toIso8601String(),
      'end_date': travel.endDate.toIso8601String(),
      'status': travel.status.index,
      'budget': travel.budget,
      'actual_cost': travel.actualCost,
      'people_count': travel.peopleCount,
      'photo_count': travel.photoCount,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    await db.insert('travels', travelMap);

    // 创建关联的任务
    for (final task in travel.tasks) {
      await addTask(id, task);
    }

    return travel.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
  }

  // 更新旅行
  Future<Travel> updateTravel(Travel travel) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();

    final travelMap = {
      'title': travel.title,
      'description': travel.description,
      'places': travel.places.join(','),
      'destination': travel.places.isNotEmpty ? travel.places[0] : '未知目的地',
      'start_date': travel.startDate.toIso8601String(),
      'end_date': travel.endDate.toIso8601String(),
      'status': travel.status.index,
      'budget': travel.budget,
      'actual_cost': travel.actualCost,
      'people_count': travel.peopleCount,
      'photo_count': travel.photoCount,
      'updated_at': now.toIso8601String(),
    };

    await db.update(
      'travels',
      travelMap,
      where: 'id = ?',
      whereArgs: [travel.id],
    );

    return travel.copyWith(updatedAt: now);
  }

  // 删除旅行
  Future<void> deleteTravel(String id) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // 删除关联的任务
      await txn.delete(
        'travels_tasks',
        where: 'travel_id = ?',
        whereArgs: [id],
      );

      // 删除旅行
      await txn.delete(
        'travels',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // 添加任务
  Future<Travel> addTask(String travelId, TravelTask task) async {
    final db = await _databaseHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now();

    final taskMap = {
      'id': id,
      'travel_id': travelId,
      'title': task.title,
      'description': task.description,
      'location': task.location,
      'start_time': task.startTime.toIso8601String(),
      'end_time': task.endTime.toIso8601String(),
      'is_completed': task.isCompleted ? 1 : 0,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    await db.insert('travels_tasks', taskMap);

    // 返回更新后的旅行
    return await _getTravelById(travelId);
  }

  // 更新任务
  Future<Travel> updateTask(String travelId, TravelTask task) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();

    final taskMap = {
      'title': task.title,
      'description': task.description,
      'location': task.location,
      'start_time': task.startTime.toIso8601String(),
      'end_time': task.endTime.toIso8601String(),
      'is_completed': task.isCompleted ? 1 : 0,
      'updated_at': now.toIso8601String(),
    };

    await db.update(
      'travels_tasks',
      taskMap,
      where: 'id = ?',
      whereArgs: [task.id],
    );

    // 返回更新后的旅行
    return await _getTravelById(travelId);
  }

  // 删除任务
  Future<Travel> deleteTask(String travelId, String taskId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'travels_tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );

    // 返回更新后的旅行
    return await _getTravelById(travelId);
  }

  // 获取旅行的所有任务
  Future<List<TravelTask>> _getTasksForTravel(String travelId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> taskMaps = await db.query(
      'travels_tasks',
      where: 'travel_id = ?',
      whereArgs: [travelId],
    );

    return taskMaps.map((map) => _mapToTask(map)).toList();
  }

  // 根据ID获取旅行
  Future<Travel> _getTravelById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'travels',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Travel not found');
    }

    final tasks = await _getTasksForTravel(id);
    return _mapToTravel(maps.first, tasks);
  }

  // 将数据库记录映射为Travel实体
  Travel _mapToTravel(Map<String, dynamic> map, List<TravelTask> tasks) {
    return Travel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      places: (map['places'] as String).split(','),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      status: TravelStatus.values[map['status'] as int],
      tasks: tasks,
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      actualCost: map['actual_cost'] != null
          ? (map['actual_cost'] as num).toDouble()
          : null,
      peopleCount: (map['people_count'] as int?) ?? 1,
      photoCount: map['photo_count'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // 将数据库记录映射为TravelTask实体
  TravelTask _mapToTask(Map<String, dynamic> map) {
    return TravelTask(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
