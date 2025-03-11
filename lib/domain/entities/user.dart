class User {
  final String id;
  final String username;
  final String nickname;
  final String? avatar;
  final String? email;
  final String? phone;
  final String? gender;
  final String? birthday;
  final String? signature;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.nickname,
    this.avatar,
    this.email,
    this.phone,
    this.gender,
    this.birthday,
    this.signature,
    required this.createdAt,
    required this.updatedAt,
  });
} 