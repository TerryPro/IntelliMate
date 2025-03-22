import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/domain/core/memo_config.dart';

class MemoItem extends StatelessWidget {
  final Memo memo;
  final Function(String) onEdit;
  final Function(String) onDelete;

  const MemoItem({
    super.key,
    required this.memo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(memo.category ?? '其他');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: categoryColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(0x0D),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onEdit(memo.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(memo.category ?? '其他'),
                            size: 18,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              memo.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(0x1A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        memo.category ?? '其他',
                        style: TextStyle(
                          fontSize: 12,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  memo.content ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(memo.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => onEdit(memo.id),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => onDelete(memo.id),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    return MemoConfig.getCategoryColor(category);
  }

  IconData _getCategoryIcon(String category) {
    return MemoConfig.getCategoryIcon(category);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }
}
