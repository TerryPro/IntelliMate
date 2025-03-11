 import 'package:intellimate/domain/entities/user.dart';

abstract class UserRepository {
  // 获取当前用户
  Future<User?> getCurrentUser();
  
  // 登录并设置当前用户
  Future<bool> login(String userId);
  
  // 登出
  Future<bool> logout();
  
  // 获取用户
  Future<User?> getUserById(String id);
  
  // 创建用户
  Future<User> createUser(User user);
  
  // 更新用户
  Future<bool> updateUser(User user);
  
  // 删除用户
  Future<bool> deleteUser(String id);
}