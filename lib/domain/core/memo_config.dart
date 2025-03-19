import 'package:flutter/material.dart';

class MemoConfig {
  // 备忘录类型配置
  static const Map<String, IconData> categoryIcons = {
    '工作': Icons.work,
    '学习': Icons.school,
    '生活': Icons.home,
    '其他': Icons.note,
  };

  static const Map<String, Color> categoryColors = {
    '工作': Color(0xFFF57C00),
    '学习': Color(0xFF66BB6A),
    '生活': Color(0xFF42A5F5),
    '其他': Color(0xFF9E9E9E),
  };

  static const List<String> categories = ['工作', '学习', '生活', '其他'];

  static Color getCategoryColor(String? category) {
    return categoryColors[category] ?? Colors.grey;
  }

  static String getCategoryText(String? category) {
    return category ?? '其他';
  }

  static IconData getCategoryIcon(String? category) {
    return categoryIcons[category] ?? Icons.category;
  }
}
