import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_theme.dart';

class ModuleCard extends StatelessWidget {
  final String moduleKey;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double height;
  final double width;

  const ModuleCard({
    super.key,
    required this.moduleKey,
    required this.title,
    required this.icon,
    required this.onTap,
    this.height = 96,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = AppTheme.getModuleGradient(moduleKey);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 