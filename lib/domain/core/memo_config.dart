import 'package:flutter/material.dart';

enum MemoCategory {
  all('全部', Icons.all_inclusive, Color(0xFF3ECABB)),
  work('工作', Icons.work, Color(0xFFF57C00)),
  study('学习', Icons.school, Color(0xFF66BB6A)),
  life('生活', Icons.home, Color(0xFF42A5F5)),
  other('其他', Icons.note, Color(0xFF9E9E9E));

  final String name;
  final IconData icon;
  final Color color;

  const MemoCategory(this.name, this.icon, this.color);
}

class MemoConfig {
  // 获取所有类别名称
  static List<String> get categories =>
      MemoCategory.values.map((e) => e.name).toList();

  // 获取除all之外的所有类别名称
  static List<String> get nonAllCategories => MemoCategory.values
      .where((e) => e != MemoCategory.all)
      .map((e) => e.name)
      .toList();

  // 根据类别名称获取颜色
  static Color getCategoryColor(String? category) {
    return MemoCategory.values
        .firstWhere((e) => e.name == category, orElse: () => MemoCategory.other)
        .color;
  }

  // 根据类别名称获取图标
  static IconData getCategoryIcon(String? category) {
    return MemoCategory.values
        .firstWhere((e) => e.name == category, orElse: () => MemoCategory.other)
        .icon;
  }

  // 根据类别名称获取标准化名称
  static String getCategoryText(String? category) {
    return MemoCategory.values
        .firstWhere((e) => e.name == category, orElse: () => MemoCategory.other)
        .name;
  }
}
