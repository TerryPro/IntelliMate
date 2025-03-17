import 'package:intellimate/domain/entities/travel.dart';

abstract class TravelRepository {
  // 获取所有旅行
  Future<List<Travel>> getAllTravels();
  
  // 根据状态获取旅行
  Future<List<Travel>> getTravelsByStatus(TravelStatus status);
  
  // 获取单个旅行详情
  Future<Travel?> getTravelById(String id);
  
  // 添加旅行
  Future<String> addTravel(Travel travel);
  
  // 更新旅行
  Future<void> updateTravel(Travel travel);
  
  // 删除旅行
  Future<void> deleteTravel(String id);
  
  // 添加旅行任务
  Future<String> addTravelTask(String travelId, TravelTask task);
  
  // 更新旅行任务
  Future<void> updateTravelTask(String travelId, TravelTask task);
  
  // 删除旅行任务
  Future<void> deleteTravelTask(String taskId);

  Future<Travel> addTask(String travelId, TravelTask task);
  Future<Travel> updateTask(String travelId, TravelTask task);
  Future<Travel> deleteTask(String travelId, String taskId);
} 