import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_theme.dart';
import 'package:intellimate/presentation/widgets/app_bar_widget.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String moduleKey;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.moduleKey,
  });

  @override
  Widget build(BuildContext context) {
    // 获取模块的主题色
    final List<Color> gradientColors = AppTheme.getModuleGradient(moduleKey);
    
    return Scaffold(
      appBar: AppBarWidget(
        title: title,
        backgroundColor: gradientColors[0],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: gradientColors[0].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 60,
                color: gradientColors[0],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '该功能模块正在开发中，敬请期待...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gradientColors[0],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
} 