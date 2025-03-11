class Goal {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final double progress; // 0-100
  final String status; // 未开始, 进行中, 已完成, 已放弃
  final String? category;
  final List<String>? milestones;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    required this.progress,
    required this.status,
    this.category,
    this.milestones,
    required this.createdAt,
    required this.updatedAt,
  });
} 