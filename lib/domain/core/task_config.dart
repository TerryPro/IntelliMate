import 'package:flutter/material.dart';

class TaskConfig {
  // 任务类型配置
  static const Map<String, Color> categoryColors = {
    '个人': Color(0xFF42A5F5),
    '家庭': Color(0xFFEF5350),
    '工作': Color(0xFF3ECABB),
    '学习': Color(0xFF66BB6A),
    '购物': Color(0xFFFFA726),
  };

  static const List<String> categories = ['个人', '家庭', '工作', '学习', '购物'];

  static Color getCategoryColor(String? category) {
    return categoryColors[category] ?? Colors.grey;
  }

  // 任务优先级配置
  static const Map<int, String> priorityTexts = {
    1: '低优先级',
    2: '中优先级',
    3: '高优先级',
  };

  static const Map<int, Color> priorityColors = {
    1: Colors.blue,
    2: Colors.orange,
    3: Colors.red,
  };

  static String getPriorityText(int? priority) {
    return priorityTexts[priority] ?? '';
  }

  static Color getPriorityColor(int? priority) {
    return priorityColors[priority] ?? Colors.grey;
  }
}
