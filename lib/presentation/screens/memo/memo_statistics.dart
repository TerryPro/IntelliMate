import 'package:flutter/material.dart';
import 'package:intellimate/domain/core/memo_config.dart';
import 'package:intellimate/domain/entities/memo.dart';

class MemoStatistics extends StatelessWidget {
  final List<Memo> memos;
  final Function(String category)? onCategorySelected;

  const MemoStatistics({
    super.key,
    required this.memos,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // 计算各类别的备忘录数量（基于所有数据）
    final Map<MemoCategory, int> categoryCounts = {
      for (var category in MemoCategory.values) category: 0
    };

    for (var memo in memos) {
      final category = MemoCategory.values.firstWhere(
        (e) => e.name == memo.category,
        orElse: () => MemoCategory.other,
      );
      categoryCounts[category] = categoryCounts[category]! + 1;
    }

    // 设置全部类别的数量
    categoryCounts[MemoCategory.all] = memos.length;

    return Container(
      padding: const EdgeInsets.all(12), // 减少内边距
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // 减少圆角半径
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Row(
            children: MemoCategory.values.map((category) {
              return Expanded(
                child: _buildStatItem(
                  count: categoryCounts[category]!,
                  label: category.name,
                  color: category.color,
                  onTap: () => onCategorySelected?.call(category.name),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6), // 增加统计块之间的间隔
        child: Container(
          width: 80, // 设置固定宽度以减少统计块的宽度
          padding: const EdgeInsets.symmetric(vertical: 8), // 减少内边距
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8), // 减少圆角半径
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16, // 减小字体大小
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // 减小字体大小
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
