import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordService {
  static const String _hasPasswordKey = 'has_password';
  static const String _passwordKey = 'user_password';
  
  final FlutterSecureStorage _secureStorage;
  
  PasswordService({FlutterSecureStorage? secureStorage}) 
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  /// 检查是否已设置密码
  Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasPasswordKey) ?? false;
  }
  
  /// 设置密码
  Future<bool> setPassword(String password) async {
    try {
      // 存储密码到安全存储
      await _secureStorage.write(key: _passwordKey, value: password);
      
      // 标记密码已设置
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasPasswordKey, true);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 验证密码
  Future<bool> verifyPassword(String password) async {
    try {
      final storedPassword = await _secureStorage.read(key: _passwordKey);
      return storedPassword == password;
    } catch (e) {
      return false;
    }
  }
  
  /// 清除密码（用于重置）
  Future<bool> clearPassword() async {
    try {
      await _secureStorage.delete(key: _passwordKey);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasPasswordKey, false);
      
      return true;
    } catch (e) {
      return false;
    }
  }
} 