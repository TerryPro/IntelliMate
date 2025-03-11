import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/entities/user.dart';
import 'package:intellimate/domain/repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserProvider(this._userRepository) {
    _loadCurrentUser();
  }

  // 获取状态
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  // 加载当前用户
  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userRepository.getCurrentUser();
    } catch (e) {
      _error = '加载用户信息失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取当前用户
  Future<User?> getCurrentUser() async {
    if (_currentUser == null) {
      await _loadCurrentUser();
    }
    return _currentUser;
  }

  // 登录用户
  Future<bool> login(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userRepository.login(userId);
      if (success) {
        _currentUser = await _userRepository.getUserById(userId);
      }
      return success;
    } catch (e) {
      _error = '登录失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登出
  Future<bool> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userRepository.logout();
      if (success) {
        _currentUser = null;
      }
      return success;
    } catch (e) {
      _error = '登出失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 创建用户
  Future<User?> createUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await _userRepository.createUser(user);
      _currentUser = newUser;
      return newUser;
    } catch (e) {
      _error = '创建用户失败: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新用户
  Future<bool> updateUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userRepository.updateUser(user);
      if (success && _currentUser != null && _currentUser!.id == user.id) {
        _currentUser = user;
      }
      return success;
    } catch (e) {
      _error = '更新用户失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}