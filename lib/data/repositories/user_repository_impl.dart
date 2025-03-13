import 'package:intellimate/data/datasources/user_datasource.dart';
import 'package:intellimate/data/models/user_model.dart';
import 'package:intellimate/domain/entities/user.dart';
import 'package:intellimate/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<User?> getCurrentUser() async {
    return await _dataSource.getCurrentUser();
  }

  @override
  Future<bool> login(String userId) async {
    return await _dataSource.setCurrentUserId(userId);
  }

  @override
  Future<bool> logout() async {
    return await _dataSource.clearCurrentUserId();
  }

  @override
  Future<User?> getUserById(String id) async {
    return await _dataSource.getUserById(id);
  }

  @override
  Future<User> createUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    final userId = await _dataSource.createUser(userModel);
    
    if (userId == null) {
      throw Exception('创建用户失败');
    }
    
    // 创建后获取用户，确保返回完整的用户对象
    final createdUser = await _dataSource.getUserById(userId);
    if (createdUser == null) {
      throw Exception('创建用户后无法获取用户信息');
    }
    
    return createdUser;
  }

  @override
  Future<bool> updateUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    final result = await _dataSource.updateUser(userModel);
    return result > 0;
  }

  @override
  Future<bool> deleteUser(String id) async {
    final result = await _dataSource.deleteUser(id);
    return result > 0;
  }
}