import 'package:intellimate/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.nickname,
    super.avatar,
    super.email,
    super.phone,
    super.gender,
    super.birthday,
    super.signature,
    required super.createdAt,
    required super.updatedAt,
  });

  // 从Map创建模型对象（用于数据库读取）
  factory UserModel.fromMap(Map<String, dynamic> map) {
    
    // 辅助函数：安全地解析时间戳
    DateTime parseTimestamp(dynamic value) {
      if (value == null) {
        return DateTime.now();
      }
      
      try {
        if (value is int) {
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else if (value is String) {
          // 尝试解析为整数字符串
          final intValue = int.tryParse(value);
          if (intValue != null) {
            return DateTime.fromMillisecondsSinceEpoch(intValue);
          }
          
          // 尝试作为ISO日期格式解析
          final dateTime = DateTime.tryParse(value);
          if (dateTime != null) {
            return dateTime;
          }
          
          return DateTime.now();
        } else {
          return DateTime.now();
        }
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      nickname: map['nickname'] ?? '',
      avatar: map['avatar'],
      email: map['email'],
      phone: map['phone'],
      gender: map['gender'],
      birthday: map['birthday'],
      signature: map['signature'] ?? '',
      createdAt: parseTimestamp(map['created_at']),
      updatedAt: parseTimestamp(map['updated_at']),
    );
  }

  // 转换为Map（用于数据库写入）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'email': email,
      'phone': phone,
      'gender': gender,
      'birthday': birthday,
      'signature': signature,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 创建副本并修改部分属性
  UserModel copyWith({
    String? id,
    String? username,
    String? nickname,
    String? avatar,
    String? email,
    String? phone,
    String? gender,
    String? birthday,
    String? signature,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      signature: signature ?? this.signature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 从实体创建模型
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      nickname: user.nickname,
      avatar: user.avatar,
      email: user.email,
      phone: user.phone,
      gender: user.gender,
      birthday: user.birthday,
      signature: user.signature,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}