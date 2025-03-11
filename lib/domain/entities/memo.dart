class Memo {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String? category;
  final String priority; // 重要, 提醒, 一般
  final bool isPinned;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memo({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.category,
    required this.priority,
    required this.isPinned,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });
} 