import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intellimate/domain/repositories/travel_repository.dart';

class TravelProvider extends ChangeNotifier {
  final TravelRepository _repository;
  
  // 旅行列表
  List<Travel> _allTravels = [];
  List<Travel> _planningTravels = [];
  List<Travel> _ongoingTravels = [];
  List<Travel> _completedTravels = [];
  
  // 当前选中的旅行
  Travel? _selectedTravel;
  
  // 加载状态
  bool _isLoading = false;
  String? _error;
  
  TravelProvider(this._repository);
  
  // Getters
  List<Travel> get allTravels => _allTravels;
  List<Travel> get planningTravels => _planningTravels;
  List<Travel> get ongoingTravels => _ongoingTravels;
  List<Travel> get completedTravels => _completedTravels;
  Travel? get selectedTravel => _selectedTravel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 加载所有旅行
  Future<void> loadAllTravels() async {
    _setLoading(true);
    _clearError();
    
    try {
      _allTravels = await _repository.getAllTravels();
      _filterTravelsByStatus();
      notifyListeners();
    } catch (e) {
      _setError('加载旅行数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 根据状态加载旅行
  Future<void> loadTravelsByStatus(TravelStatus status) async {
    _setLoading(true);
    _clearError();
    
    try {
      switch (status) {
        case TravelStatus.planning:
          _planningTravels = await _repository.getTravelsByStatus(status);
          break;
        case TravelStatus.ongoing:
          _ongoingTravels = await _repository.getTravelsByStatus(status);
          break;
        case TravelStatus.completed:
          _completedTravels = await _repository.getTravelsByStatus(status);
          break;
      }
      notifyListeners();
    } catch (e) {
      _setError('加载${_getTravelStatusText(status)}旅行数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 加载旅行详情
  Future<void> loadTravelDetails(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      _selectedTravel = await _repository.getTravelById(id);
      notifyListeners();
    } catch (e) {
      _setError('加载旅行详情失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 获取单个旅行
  Future<Travel?> getTravel(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final travel = await _repository.getTravelById(id);
      return travel;
    } catch (e) {
      _setError('获取旅行详情失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // 添加旅行
  Future<String?> addTravel(Travel travel) async {
    _setLoading(true);
    _clearError();
    
    try {
      final id = await _repository.addTravel(travel);
      await loadAllTravels(); // 重新加载数据
      return id;
    } catch (e) {
      _setError('添加旅行失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // 更新旅行
  Future<bool> updateTravel(Travel travel) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _repository.updateTravel(travel);
      
      // 如果更新的是当前选中的旅行，更新选中的旅行
      if (_selectedTravel != null && _selectedTravel!.id == travel.id) {
        _selectedTravel = travel;
      }
      
      await loadAllTravels(); // 重新加载数据
      return true;
    } catch (e) {
      _setError('更新旅行失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 删除旅行
  Future<bool> deleteTravel(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _repository.deleteTravel(id);
      
      // 如果删除的是当前选中的旅行，清空选中的旅行
      if (_selectedTravel != null && _selectedTravel!.id == id) {
        _selectedTravel = null;
      }
      
      await loadAllTravels(); // 重新加载数据
      return true;
    } catch (e) {
      _setError('删除旅行失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 添加旅行任务
  Future<String?> addTask(String travelId, TravelTask task) async {
    _setLoading(true);
    _clearError();
    
    try {
      final taskId = await _repository.addTravelTask(travelId, task);
      
      // 如果添加的是当前选中旅行的任务，重新加载选中的旅行
      if (_selectedTravel != null && _selectedTravel!.id == travelId) {
        await loadTravelDetails(travelId);
      }
      
      return taskId;
    } catch (e) {
      _setError('添加旅行任务失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // 更新旅行任务
  Future<bool> updateTask(String travelId, TravelTask task) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _repository.updateTravelTask(travelId, task);
      
      // 如果更新的是当前选中旅行的任务，重新加载选中的旅行
      if (_selectedTravel != null && _selectedTravel!.id == travelId) {
        await loadTravelDetails(travelId);
      }
      
      return true;
    } catch (e) {
      _setError('更新旅行任务失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 删除旅行任务
  Future<bool> deleteTask(String travelId, String taskId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _repository.deleteTravelTask(taskId);
      
      // 如果删除的是当前选中旅行的任务，重新加载选中的旅行
      if (_selectedTravel != null && _selectedTravel!.id == travelId) {
        await loadTravelDetails(travelId);
      }
      
      return true;
    } catch (e) {
      _setError('删除旅行任务失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // 设置错误信息
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  // 清除错误信息
  void _clearError() {
    _error = null;
  }
  
  // 根据状态过滤旅行
  void _filterTravelsByStatus() {
    _planningTravels = _allTravels.where((travel) => travel.status == TravelStatus.planning).toList();
    _ongoingTravels = _allTravels.where((travel) => travel.status == TravelStatus.ongoing).toList();
    _completedTravels = _allTravels.where((travel) => travel.status == TravelStatus.completed).toList();
  }
  
  // 获取旅行状态文本
  String _getTravelStatusText(TravelStatus status) {
    switch (status) {
      case TravelStatus.planning:
        return '计划中';
      case TravelStatus.ongoing:
        return '进行中';
      case TravelStatus.completed:
        return '已完成';
    }
  }
} 