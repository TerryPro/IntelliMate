import 'package:flutter/foundation.dart';
import 'package:intellimate/data/services/password_service.dart';

class PasswordProvider extends ChangeNotifier {
  final PasswordService _passwordService;
  
  bool _isLoading = false;
  bool _hasPassword = false;
  String? _error;
  
  PasswordProvider({PasswordService? passwordService}) 
    : _passwordService = passwordService ?? PasswordService() {
    _checkPassword();
  }
  
  // 状态 getters
  bool get isLoading => _isLoading;
  bool get hasPassword => _hasPassword;
  String? get error => _error;
  
  // 检查是否已设置密码
  Future<void> _checkPassword() async {
    _setLoading(true);
    
    try {
      _hasPassword = await _passwordService.hasPassword();
    } catch (e) {
      _setError('检查密码状态失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 设置密码
  Future<bool> setPassword(String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _passwordService.setPassword(password);
      if (success) {
        _hasPassword = true;
      }
      return success;
    } catch (e) {
      _setError('设置密码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 验证密码
  Future<bool> verifyPassword(String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      return await _passwordService.verifyPassword(password);
    } catch (e) {
      _setError('验证密码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 清除密码
  Future<bool> clearPassword() async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _passwordService.clearPassword();
      if (success) {
        _hasPassword = false;
      }
      return success;
    } catch (e) {
      _setError('清除密码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 辅助方法
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 