class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? category;
  final int? priority; // 1-低, 2-中, 3-高
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.isCompleted,
    this.category,
    this.priority,
    required this.createdAt,
    required this.updatedAt,
  });
} 