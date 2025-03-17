import 'package:intellimate/data/datasources/travel_datasource.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intellimate/domain/repositories/travel_repository.dart';

class TravelRepositoryImpl implements TravelRepository {
  final TravelDataSource _dataSource;
  
  TravelRepositoryImpl(this._dataSource);
  
  @override
  Future<List<Travel>> getAllTravels() async {
    return await _dataSource.getTravels();
  }
  
  @override
  Future<List<Travel>> getTravelsByStatus(TravelStatus status) async {
    final travels = await _dataSource.getTravels();
    return travels.where((travel) => travel.status == status).toList();
  }
  
  @override
  Future<Travel?> getTravelById(String id) async {
    try {
      final travels = await _dataSource.getTravels();
      return travels.firstWhere((travel) => travel.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<String> addTravel(Travel travel) async {
    final newTravel = await _dataSource.createTravel(travel);
    return newTravel.id!;
  }
  
  @override
  Future<void> updateTravel(Travel travel) async {
    await _dataSource.updateTravel(travel);
  }
  
  @override
  Future<void> deleteTravel(String id) async {
    await _dataSource.deleteTravel(id);
  }
  
  @override
  Future<String> addTravelTask(String travelId, TravelTask task) async {
    final travel = await _dataSource.addTask(travelId, task);
    final addedTask = travel.tasks.firstWhere((t) => t.title == task.title);
    return addedTask.id!;
  }
  
  @override
  Future<void> updateTravelTask(String travelId, TravelTask task) async {
    await _dataSource.updateTask(travelId, task);
  }
  
  @override
  Future<void> deleteTravelTask(String taskId) async {
    // 由于 TravelDataSource 的 deleteTask 方法需要 travelId，
    // 我们需要先获取任务所属的旅行 ID
    final travels = await _dataSource.getTravels();
    for (final travel in travels) {
      if (travel.tasks.any((task) => task.id == taskId)) {
        await _dataSource.deleteTask(travel.id!, taskId);
        return;
      }
    }
  }
  
  @override
  Future<Travel> addTask(String travelId, TravelTask task) async {
    return await _dataSource.addTask(travelId, task);
  }
  
  @override
  Future<Travel> updateTask(String travelId, TravelTask task) async {
    return await _dataSource.updateTask(travelId, task);
  }
  
  @override
  Future<Travel> deleteTask(String travelId, String taskId) async {
    return await _dataSource.deleteTask(travelId, taskId);
  }
} 