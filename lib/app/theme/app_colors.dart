import 'package:flutter/material.dart';

/// Color类扩展方法
extension ColorExtension on Color {
  /// 用于替代withOpacity，但允许更多自定义参数
  Color withValues({
    int? red,
    int? green,
    int? blue,
    double? alpha,
  }) {
    return Color.fromRGBO(
      red ?? r.toInt(), 
      green ?? g.toInt(), 
      blue ?? b.toInt(),
      alpha ?? a,
    );
  }
}

/// 应用颜色工具类
class AppColors {
  // 主题颜色
  static const Color primary = Color(0xFF3ECABB);
  static const Color primaryLight = Color(0xFFD5F5F2);
  
  // 常用透明度颜色
  static const Color white = Colors.white;
  static const Color whiteWithOpacity20 = Color(0x33FFFFFF); // 20%透明度的白色
  
  static const Color black = Colors.black;
  static const Color blackWithOpacity05 = Color(0x0D000000); // 5%透明度的黑色
  static const Color blackWithOpacity10 = Color(0x1A000000); // 10%透明度的黑色
  static const Color blackWithOpacity50 = Color(0x80000000); // 50%透明度的黑色
  
  // 主题颜色透明度变体
  static const Color primaryWithOpacity10 = Color(0x1A3ECABB); // 10%透明度的主题色
  
  // 功能颜色
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.amber;
  static const Color info = Colors.blue;
  
  // 文本颜色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  
  // 背景颜色
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // 获取颜色的透明度变体
  static Color getColorWithOpacity(Color color, double opacity) {
    return Color.fromRGBO(
      color.r.toInt(),
      color.g.toInt(), 
      color.b.toInt(),
      opacity,
    );
  }
} 